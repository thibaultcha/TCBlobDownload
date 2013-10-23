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
@dynamic pathToFile;


#pragma mark - Init


- (id)initWithURL:(NSURL *)url
     downloadPath:(NSString *)pathToDL
         delegate:(id<TCBlobDownloadDelegate>)delegateOrNil

{
    self = [super init];
    if (self) {
        self.downloadURL = url;
        self.delegate = delegateOrNil;
        self.pathToDownloadDirectory = pathToDL;
    }
    return self;
}

- (id)initWithURL:(NSURL *)url
     downloadPath:(NSString *)pathToDL
    firstResponse:(FirstResponseBlock)firstResponseBlock
         progress:(ProgressBlock)progressBlock
            error:(ErrorBlock)errorBlock
         complete:(CompleteBlock)completeBlock
{
    self = [self initWithURL:url downloadPath:pathToDL delegate:nil];
    if (self) {
        self.firstResponseBlock = firstResponseBlock;
        self.progressBlock = progressBlock;
        self.errorBlock = errorBlock;
        self.completeBlock = completeBlock;
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
    // File already exists or not
    if (![fm fileExistsAtPath:self.pathToFile]) {
        [fm createFileAtPath:self.pathToFile
                    contents:nil
                  attributes:nil];
        TCLog(@"Created file at path: %@", self.pathToFile);
    }
    else {
        uint64_t fileSize = [[fm attributesOfItemAtPath:self.pathToFile error:nil] fileSize];
        NSString *range = [NSString stringWithFormat:@"bytes=%lld-", fileSize];
        [fileRequest setValue:range forHTTPHeaderField:@"Range"];
    }
    
    _file = [NSFileHandle fileHandleForWritingAtPath:self.pathToFile];
    [self.file seekToEndOfFile];
    _receivedDataBuffer = [[NSMutableData alloc] init];
    _connection = [[NSURLConnection alloc] initWithRequest:fileRequest
                                                  delegate:self
                                          startImmediately:NO];
    if (self.connection) {
        TCLog(@"Operation started for file:\n%@", self.pathToFile);
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
    TCLog(@"Download failed. Error - %@ %@",
          [error localizedDescription],
          [error userInfo][NSURLErrorFailingURLStringErrorKey]);
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
    NSHTTPURLResponse *httpUrlResponse = (NSHTTPURLResponse *)response;
    
    __autoreleasing NSError *error;
    
    if (httpUrlResponse.statusCode >= 400) {
        error = [NSError errorWithDomain:kErrorDomain
                                    code:2
                                userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:NSLocalizedString(@"HTTP error code %d (%@) ", @"HTTP error code {satus code} ({status code description})"),
                                                                      httpUrlResponse.statusCode,
                                                                      [NSHTTPURLResponse localizedStringForStatusCode:httpUrlResponse.statusCode]]}];
    }
    
    if ([TCBlobDownload freeDiskSpace] < _expectedDataLength && _expectedDataLength != -1) {
        error = [NSError errorWithDomain:kErrorDomain
                                    code:1
                                userInfo:@{NSLocalizedDescriptionKey:
                                               NSLocalizedString(@"Not enough free disk space", @"")}];
    }
    
    if (error) {
        TCLog(@"Download failed. Error - %@ %@",
              [error localizedDescription],
              [error userInfo][NSURLErrorFailingURLStringErrorKey]);
        
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
    
    TCLog(@"%@ | %.2f%% - Received: %lld - Total: %lld",
          self.fileName, (float) _receivedDataLength / _expectedDataLength * 100, _receivedDataLength, _expectedDataLength);
    
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
    TCLog(@"Download succeeded. Bytes received: %lld", _receivedDataLength);
    [self.file writeData:self.receivedDataBuffer];
    [self.receivedDataBuffer setData:nil];
    
    if (self.completeBlock) {
        self.completeBlock(YES, self.pathToFile);
    }
    if ([self.delegate respondsToSelector:@selector(download:didFinishWithSucces:atPath:)]) {
        [self.delegate download:self didFinishWithSucces:YES atPath:self.pathToFile];
    }
    
    [self finishOperation];
}


#pragma mark - Utilities


- (void)finishOperation
{
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    [self.connection cancel];
    [self setConnection:nil];
    [self.file closeFile];
    [self didChangeValueForKey:@"isFinished"];
    [self didChangeValueForKey:@"isExecuting"];
    TCLog(@"Operation ended for file %@", self.fileName);
}

- (void)cancelDownloadAndRemoveFile:(BOOL)remove
{
    [self finishOperation];
    TCLog(@"Cancel download received for file %@", self.pathToFile);
    NSFileManager *fm = [NSFileManager defaultManager];
    
    if (remove && [fm fileExistsAtPath:self.pathToFile]) {
        __autoreleasing NSError *fileError;
        [fm removeItemAtPath:self.pathToFile error:&fileError];
        if (fileError) {
            TCLog(@"An error occured while removing file - %@", fileError);
            // TODO handle error
        }
    }
    
    if (self.completeBlock) {
        self.completeBlock(NO, nil);
    }
    if ([self.delegate respondsToSelector:@selector(download:didFinishWithSucces:atPath:)]) {
        [self.delegate download:self didFinishWithSucces:NO atPath:nil];
    }
}

- (void)addDependentDownload:(TCBlobDownload *)blobDownload
{
    [self addDependency:blobDownload];
}

+ (uint64_t)freeDiskSpace
{
    //uint64_t totalSpace = 0;
    uint64_t totalFreeSpace = 0;
    
    __autoreleasing NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject]
                                                                                       error:&error];
    if (dictionary) {
        //NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
        NSNumber *freeFileSystemSizeInBytes = dictionary[NSFileSystemFreeSize];
        //totalSpace = [fileSystemSizeInBytes unsignedLongLongValue];
        totalFreeSpace = [freeFileSystemSizeInBytes unsignedLongLongValue];
        //TCLog(@"Memory Capacity of %llu MiB with %llu MiB Free memory available.", ((totalSpace/1024ll)/1024ll), ((totalFreeSpace/1024ll)/1024ll));
    }
    else {
        TCLog(@"Error obtaining system memory infos: Domain = %@, Code = %d",
              [error domain],
              [error code]);
    }
    return totalFreeSpace;
}


#pragma mark - Getters


- (NSString *)fileName
{
    return [[NSURL URLWithString:[self.downloadURL absoluteString]] lastPathComponent];
}

- (NSString *)pathToFile
{
    return [self.pathToDownloadDirectory stringByAppendingPathComponent:self.fileName];
}

@end
