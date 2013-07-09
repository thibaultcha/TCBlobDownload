//
//  TCBlobDownload.m
//
//  Created by Thibault Charbonnier on 15/04/13.
//  Copyright (c) 2013 Thibault Charbonnier. All rights reserved.
//

const double kBufferSize = 1024*1024; // 1 MB
const NSTimeInterval kDefaultTimeout = 30;
NSString * const kErrorDomain = @"com.thibaultcha.tcblobdownload";

#import "TCBlobDownload.h"

@interface TCBlobDownload ()
{
    uint64_t _receivedDataLength;
    uint64_t _expectedDataLength;
}
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *receivedDataBuffer;
@property (nonatomic, strong) NSFileHandle *file;
@property (nonatomic, copy) FirstResponseBlock firstResponseBlock;
@property (nonatomic, copy) ProgressBlock progressBlock;
@property (nonatomic, copy) ErrorBlock errorBlock;
@property (nonatomic, copy) CompleteBlock completeBlock;
+ (uint64_t)freeDiskSpace;
- (void)finishOperation;
@end

@implementation TCBlobDownload
@dynamic fileName;


#pragma mark - Init


- (id)initWithUrl:(NSURL *)url
     downloadPath:(NSString *)pathToDL
      andDelegate:(id<TCBlobDownloadDelegate>)delegateOrNil

{
    NSAssert(pathToDL != nil, @"Download path cannot be nil for TCBlobDownload.");
    self = [super init];
    if (self) {
        _downloadURL = url;
        _delegate = delegateOrNil;
        if ([TCBlobDownload createPathFromPath:pathToDL]) {
            _pathToDownloadDirectory = pathToDL;
        }
    }
    return self;
}

- (id)initWithUrl:(NSURL *)url
     downloadPath:(NSString *)pathToDL
    firstResponse:(FirstResponseBlock)firstResponseBlock
         progress:(ProgressBlock)progressBlock
            error:(ErrorBlock)errorBlock
         complete:(CompleteBlock)completeBlock
{
    self = [self initWithUrl:url downloadPath:pathToDL andDelegate:nil];
    if (self) {
        _firstResponseBlock = firstResponseBlock;
        _progressBlock = progressBlock;
        _errorBlock = errorBlock;
        _completeBlock = completeBlock;
    }
    return self;
}


#pragma mark - NSOperation Override


- (void)start
{
    NSMutableURLRequest *fileRequest = [NSMutableURLRequest requestWithURL:self.downloadURL
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:kDefaultTimeout];
    
    NSAssert([NSURLConnection canHandleRequest:fileRequest], @"NSURLConnection can't handle provided request");
    
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
    
    _file = [NSFileHandle fileHandleForWritingAtPath:filePath];
    [self.file seekToEndOfFile];
    _receivedDataBuffer = [[NSMutableData alloc] init];
    _connection = [[NSURLConnection alloc] initWithRequest:fileRequest
                                                  delegate:self
                                          startImmediately:NO];
    if (self.connection) {
#ifdef DEBUG
        NSLog(@"Operation started for file:\n%@", filePath);
#endif
        [self.connection scheduleInRunLoop:[NSRunLoop mainRunLoop]
                               forMode:NSDefaultRunLoopMode];
        [self willChangeValueForKey:@"isExecuting"];
        [self.connection start];
        [self didChangeValueForKey:@"isExecuting"];
    }
}

- (BOOL)isExecuting
{
    return self.connection != nil;
}

- (BOOL)isFinished
{
    return self.connection == nil;
}


#pragma mark - NSURLConnection Delegate


- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError *)error
{
#ifdef DEBUG
    NSLog(@"Download failed. Error - %@ %@",
          [error localizedDescription],
          [error userInfo][NSURLErrorFailingURLStringErrorKey]);
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
    
    if ([TCBlobDownload freeDiskSpace] < _expectedDataLength
        && _expectedDataLength != -1) {
        __autoreleasing NSError *error = [NSError errorWithDomain:kErrorDomain
                                                             code:1
                                                         userInfo:@{NSLocalizedDescriptionKey:
                                                                    NSLocalizedString(@"Not enough free disk space", @"")}];
#ifdef DEBUG
        NSLog(@"Download failed. Error - %@ %@",
              [error localizedDescription],
              [error userInfo][NSURLErrorFailingURLStringErrorKey]);
#endif
        if (self.errorBlock) {
            self.errorBlock(error);
        }
        if ([self.delegate respondsToSelector:@selector(download:didStopWithError:)]) {
            [self.delegate download:self didStopWithError:error];
        }
        
        [self cancelDownloadAndRemoveFile:NO];
    }
    else {
        [self.receivedDataBuffer setData:nil];
        
        if (self.firstResponseBlock) {
            self.firstResponseBlock(response);
        }
        if ([self.delegate respondsToSelector:@selector(download:didReceiveFirstResponse:)]) {
            [self.delegate download:self didReceiveFirstResponse:response];
        }
    }
}

- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData *)data
{
    [self.receivedDataBuffer appendData:data];
    _receivedDataLength += [data length];
    
#ifdef DEBUG
    NSLog(@"%@ | %.2f%% - Received: %lld - Total: %lld", self.fileName, (float) _receivedDataLength / _expectedDataLength * 100, _receivedDataLength, _expectedDataLength);
#endif
    
    if (self.receivedDataBuffer.length > kBufferSize && self.file) {
        [self.file writeData:self.receivedDataBuffer];
        [self.receivedDataBuffer setData:nil];
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
    [self.file writeData:self.receivedDataBuffer];
    [self.receivedDataBuffer setData:nil];
    
    NSString *pathToFile = [self.pathToDownloadDirectory stringByAppendingPathComponent:self.fileName];
    if (self.completeBlock) {
        self.completeBlock(YES, pathToFile);
    }
    if ([self.delegate respondsToSelector:@selector(download:didFinishWithSucces:atPath:)]) {
        [self.delegate download:self didFinishWithSucces:YES atPath:pathToFile];
    }
    
    [self finishOperation];
}


#pragma mark - Utilities


- (void)finishOperation
{
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    [self.connection cancel];
    self.connection = nil;
    [self.file closeFile];
    [self didChangeValueForKey:@"isFinished"];
    [self didChangeValueForKey:@"isExecuting"];
#ifdef DEBUG
    NSLog(@"Operation ended for file %@", self.fileName);
#endif
}

- (void)cancelDownloadAndRemoveFile:(BOOL)remove
{    
    if (remove) {
        NSFileManager *fm = [NSFileManager defaultManager];
        NSString *pathToFile = [self.pathToDownloadDirectory stringByAppendingPathComponent:self.fileName];
        [fm removeItemAtPath:pathToFile error:nil];
    }
    
    if (self.completeBlock) {
        self.completeBlock(NO, nil);
    }
    if ([self.delegate respondsToSelector:@selector(download:didFinishWithSucces:atPath:)]) {
        [self.delegate download:self didFinishWithSucces:NO atPath:nil];
    }
    
    [self finishOperation];
}

- (void)addDependentDownload:(TCBlobDownload *)blobDownload
{
    [self addDependency:blobDownload];
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
    //uint64_t totalSpace = 0;
    uint64_t totalFreeSpace = 0;
    
    __autoreleasing NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject]
                                                                                       error: &error];
    if (dictionary) {
        //NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
        NSNumber *freeFileSystemSizeInBytes = dictionary[NSFileSystemFreeSize];
        //totalSpace = [fileSystemSizeInBytes unsignedLongLongValue];
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


#pragma mark - Getters


- (NSString *)fileName
{
    return [[NSURL URLWithString:[self.downloadURL absoluteString]] lastPathComponent];
}

@end
