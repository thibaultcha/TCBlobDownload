//
//  BlobDownloader.m
//
//  Created by Thibault Charbonnier on 15/04/13.
//  Copyright (c) 2013 Thibault Charbonnier. All rights reserved.
//

#import "TCBlobDownload.h"

typedef void (^ProgressBlock)(float, float);
typedef void (^ErrorBlock)(NSError *);
typedef void (^CompletionBlock)();

@interface TCBlobDownload ()
{
    NSURLConnection *_connection;
    NSMutableData *_receivedDataBuffer;
    NSFileHandle *_file;
    NSPort *_port; // Trick the NSRunLoop

    uint64_t _receivedDataLength;
    uint64_t _expectedDataLength;
}

@property (nonatomic, copy) ProgressBlock progressBlock;
@property (nonatomic, copy) ErrorBlock errorBlock;
@property (nonatomic, copy) CompletionBlock completionBlock;

+ (uint64_t)freeDiskSpace;

@end

@implementation TCBlobDownload

- (id)initWithUrlString:(NSString *)urlString
           downloadPath:(NSString *)pathToDL
            andDelegate:(id<TCBlobDownloadDelegate>)delegateOrNil

{
    if (self = [super init]) {
        NSAssert(nil != pathToDL, @"Download path cannot be nil for TCBlobDownload.");
        self.urlAdress = [NSURL URLWithString:urlString];
        self.delegate = delegateOrNil;
        if ([TCBlobDownload createPathFromPath:pathToDL])
            self.pathToDownloadDirectory = pathToDL;
    }
    
    return self;
}

- (id)initWithUrlString:(NSString *)urlString
           downloadPath:(NSString *)pathToDL
          progressBlock:(void (^)(float, float))progressBlock
             errorBlock:(void (^)(NSError *))errorBlock
        completionBlock:(void (^)())completionBlock
{
    self = [self initWithUrlString:urlString
                      downloadPath:pathToDL
                       andDelegate:nil];
    if (self) {
        _progressBlock = progressBlock;
        _errorBlock = errorBlock;
        _completionBlock = completionBlock;
    }
    
    return self;
}


#pragma mark - NSOperation override


- (void)cancel
{
    [_connection cancel];
    [_file closeFile];
    [_port invalidate]; // Remove input source so the run loop stops
    [super cancel];
}

- (void)main
{    
    NSMutableURLRequest *fileRequest = [NSMutableURLRequest requestWithURL:self.urlAdress
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:DEFAULT_TIMEOUT];
    NSAssert([NSURLConnection canHandleRequest:fileRequest], @"NSURLConnection can't handle provided request");
    
    self.fileName = [[[NSURL URLWithString:[self.urlAdress absoluteString]] path] lastPathComponent];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *filePath = [self.pathToDownloadDirectory stringByAppendingPathComponent:self.fileName];

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
    
    _receivedDataBuffer = [[NSMutableData alloc] init];
    _file = [NSFileHandle fileHandleForWritingAtPath:filePath];
    [_file seekToEndOfFile];
    _connection = [[NSURLConnection alloc] initWithRequest:fileRequest
                                                  delegate:self
                                          startImmediately:NO];
    
    if (_connection) {
#ifdef DEBUG
    NSLog(@"Operation started for file:\n%@", filePath);
#endif
        // Trick to avoid the thread to exit: new input source to the run loop
        _port = [NSPort port];
        [[NSRunLoop currentRunLoop] addPort:_port forMode:NSDefaultRunLoopMode];
        [_connection start];
        [[NSRunLoop currentRunLoop] run];
    }
}


#pragma mark - NSURLConnection Delegate


- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError *)error
{
#ifdef DEBUG
    NSLog(@"Download failed. Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
#endif
    if (self.errorBlock) {
        self.errorBlock(error);
    }
    if ([self.delegate respondsToSelector:@selector(download:didStopWithError:)]) {
        [self.delegate download:self didStopWithError:error];
    }
    
    [self cancelDownloadAndRemoveFile:NO];
}

- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse *)response
{
    _expectedDataLength = [response expectedContentLength];
    [_receivedDataBuffer setData:nil];
    
    if ([TCBlobDownload freeDiskSpace] < _expectedDataLength) {
        NSString *errorDesc = [NSString stringWithFormat:@"Not enough free space to download file %@", self.fileName];
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:errorDesc
                        forKey:NSLocalizedDescriptionKey];
        __autoreleasing NSError *error = [NSError errorWithDomain:ERROR_DOMAIN
                                             code:1
                                         userInfo:errorDetails];
        [self cancelDownloadAndRemoveFile:NO];
#ifdef DEBUG
        NSLog(@"Download failed. Error - %@", [error localizedDescription]);
#endif
        if (self.errorBlock) {
            self.errorBlock(error);
        }
        if ([self.delegate respondsToSelector:@selector(download:didStopWithError:)]) {
            [self.delegate download:self didStopWithError:error];
        }
    }
}

- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData *)data
{    
    [_receivedDataBuffer appendData:data];
    _receivedDataLength += [data length];

#ifdef DEBUG
    //float percent = (float) _receivedDataLength / _expectedDataLength * 100;
    //NSLog(@"%@ | %.2f%% - Received: %lld - Total: %lld",
    //      self.fileName, percent, _receivedDataLength, _expectedDataLength);
#endif
    
    if (_receivedDataBuffer.length > BUFFER_SIZE && _file) {
        [_file writeData:_receivedDataBuffer];
        [_receivedDataBuffer setData:nil];
    }
    
    if (self.progressBlock) {
        self.progressBlock(_receivedDataLength, _expectedDataLength);
    }
    if ([self.delegate respondsToSelector:@selector(download:didReceiveData:onTotal:)]) {
        [self.delegate download:self
                   didReceiveData:_receivedDataLength
                          onTotal:_expectedDataLength];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection*)connection
{
#ifdef DEBUG
    NSLog(@"Download succeeded. Bytes received: %lld", _receivedDataLength);
#endif
    if (self.completionBlock) {
        self.completionBlock();
    }
    if ([self.delegate respondsToSelector:@selector(downloadDidFinishWithDownload:)]) {
        [self.delegate downloadDidFinishWithDownload:self];
    }
    
    [self cancelDownloadAndRemoveFile:NO];
}


#pragma mark - Utilities


- (void)cancelDownloadAndRemoveFile:(BOOL)remove
{
#ifdef DEBUG
    NSLog(@"Operation ended for file %@", self.fileName);
#endif
    if (remove) {
        NSFileManager *fm = [NSFileManager defaultManager];
        [fm removeItemAtPath:self.pathToDownloadDirectory error:nil];
    }

    [self cancel];
}

+ (BOOL)createPathFromPath:(NSString *)path
{
    NSFileManager *fm = [NSFileManager defaultManager];
    
    if ([fm fileExistsAtPath:path]) {
        return true;
    } else {
        NSError *error = nil;
        BOOL created = [fm createDirectoryAtPath:path
                     withIntermediateDirectories:YES
                                      attributes:nil
                                           error:&error];
        if (error) {
#ifdef DEBUG
        NSLog(@"Error creating download directory - %@ %d",
              [error localizedDescription],
              [error code]);
#endif
        }
        
        return created;
    }
}

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
