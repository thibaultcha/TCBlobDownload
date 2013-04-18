//
//  BlobDownloader.m
//
//  Created by Thibault Charbonnier on 15/04/13.
//  Copyright (c) 2013 Thibault Charbonnier. All rights reserved.
//

#import "BlobDownloader.h"

@interface BlobDownloader ()
{
    NSURLConnection *_connection;
    NSMutableData *_receivedData;
    NSFileHandle *_handleFile;
    NSString *_fileName;
    NSPort *_port; // Trick the NSRunLoop

    uint64_t _receivedDataLength;
    uint64_t _totalDataLength;
}

- (void)cancelDownload;
+ (uint64_t)freeDiskSpace;

@end

@implementation BlobDownloader


#pragma mark - Utilities


- (id)initWithUrlString:(NSString *)url andDelegate:(id<BlobDownloaderDelegate>)delegate
{
    if (self = [super init]) {
        self.urlAdress = [NSURL URLWithString:url];
        self.delegate = delegate;
    }
    
    return self;
}


- (void)cancelDownload
{
    [_connection cancel];
    [_handleFile closeFile];
    [_port invalidate];
    
#ifdef DEBUG
    NSLog(@"Operation cancelled for file %@", _fileName);
#endif
    
}


#pragma mark - NSOperation override


- (void)main
{    
    NSMutableURLRequest *fileRequest = [NSMutableURLRequest requestWithURL:self.urlAdress
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:DEFAULT_TIMEOUT];
    
    _fileName = [[[NSURL URLWithString:[self.urlAdress absoluteString]] path] lastPathComponent];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *folder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/"];
    NSString *filePath = [folder stringByAppendingPathComponent:_fileName];

    // File already exists or not
    if (![fm fileExistsAtPath:filePath]) {
        [fm createFileAtPath:filePath
                    contents:nil
                  attributes:nil];
    } else {
        uint64_t fileSize = [[fm attributesOfItemAtPath:filePath error:nil] fileSize];
        NSString *range = [NSString stringWithFormat:@"bytes=%lld-", fileSize];
        [fileRequest setValue:range forHTTPHeaderField:@"Range"];
    }
    
    _receivedData = [[NSMutableData alloc] init];
    _handleFile = [NSFileHandle fileHandleForWritingAtPath:filePath];
    [_handleFile seekToEndOfFile];
    _connection = [[NSURLConnection alloc] initWithRequest:fileRequest
                                                  delegate:self
                                          startImmediately:NO];
    
    if (_connection) {

#ifdef DEBUG
    NSLog(@"Connection started for download at path:\n%@", filePath);
#endif
        
        if ([self isCancelled]) {
            [self cancelDownload];
            return;
        }
        
        // Trick to avoid the thread to exit: new input source to the run loop
        _port = [NSPort port];
        [[NSRunLoop currentRunLoop] addPort:_port forMode:NSDefaultRunLoopMode];
        [_connection start];
        [[NSRunLoop currentRunLoop] run];
    } else {
        
#ifdef DEBUG
    NSLog(@"Connection failed.");
#endif
        
    }
}


#pragma mark - NSURLConnection management


- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError *)error
{
    [_receivedData setData:nil];
    [_handleFile closeFile];
    [_port invalidate]; // Remove input source so the run loop stops

#ifdef DEBUG
    NSLog(@"Connection failed. Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
#endif
    
    if ([self.delegate respondsToSelector:@selector(downloaderDidFailWithError:)]) {
        [self.delegate downloaderDidFailWithError:&error];
    }
}

- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse *)response
{
    _totalDataLength = [response expectedContentLength];
    [_receivedData setData:nil];
    
    if ([BlobDownloader freeDiskSpace] < _totalDataLength) {
        [self cancel];
        NSString *errorDesc = [NSString stringWithFormat:@"Not enough free space to download file %@",
                               _fileName,
                               nil];
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:errorDesc
                        forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:ERROR_DOMAIN
                                             code:1
                                         userInfo:errorDetails];
        
#ifdef DEBUG
    NSLog(@"Download failed. Error - %@", [error localizedDescription]);
#endif
        
        if ([self.delegate respondsToSelector:@selector(downloaderDidFailWithError:)]) {
            [self.delegate downloaderDidFailWithError:&error];
        }
    }
}

- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData *)data
{
    if ([self isCancelled]) {
        [self cancelDownload];
        return;
    }
    
    [_receivedData appendData:data];
    _receivedDataLength += [data length];

#ifdef DEBUG
    float percent = (float) _receivedDataLength / _totalDataLength * 100;
    NSLog(@"%@ | %.2f%% - Received: %lld - Total: %lld",
          _fileName, percent, _receivedDataLength, _totalDataLength);
#endif
    
    if (_receivedData.length > BUFFER_SIZE && _handleFile) {
        [_handleFile writeData:_receivedData];
        [_receivedData setData:nil];
    }
    
    if ([self.delegate respondsToSelector:@selector(downloaderDidReceiveData:onTotal:)]) {
        [self.delegate downloaderDidReceiveData:_receivedDataLength
                                        onTotal:_totalDataLength];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection*)connection
{
    [_handleFile writeData:_receivedData];
    [_handleFile closeFile];
    [_port invalidate];
    
#ifdef DEBUG
    NSLog(@"Succeeded. Received %lld bytes of data.", _receivedDataLength);
#endif
    
    if ([self.delegate respondsToSelector:@selector(downloaderDidFinishLoading)]) {
        [self.delegate downloaderDidFinishLoading];
    }
}


#pragma mark - Disk Space Management


+ (uint64_t)freeDiskSpace
{
    uint64_t totalSpace = 0;
    uint64_t totalFreeSpace = 0;
    
    __autoreleasing NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject]
                                                                                       error: &error];
    
    if (dictionary) {
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        totalSpace = [fileSystemSizeInBytes unsignedLongLongValue];
        totalFreeSpace = [freeFileSystemSizeInBytes unsignedLongLongValue];
        //NSLog(@"Memory Capacity of %llu MiB with %llu MiB Free memory available.", ((totalSpace/1024ll)/1024ll), ((totalFreeSpace/1024ll)/1024ll));
    } else {
#ifdef DEBUG
    NSLog(@"Error obtaining system memory infos: Domain = %@, Code = %d",
          [error domain],
          [error code]);
#endif
    }
    
    return totalFreeSpace;
}

@end
