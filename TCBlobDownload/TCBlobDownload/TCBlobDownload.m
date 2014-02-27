//
//  TCBlobDownload.m
//
//  Created by Thibault Charbonnier on 15/04/13.
//  Copyright (c) 2013 Thibault Charbonnier. All rights reserved.
//

static const double kBufferSize = 1024*1024; // 1 MB
static const NSTimeInterval kDefaultTimeout = 30;
static NSString * const kErrorDomain = @"com.thibaultcha.tcblobdownload";
static NSString * const HTTPErrorCode = @"httpStatus";

#import "TCBlobDownload.h"

@interface TCBlobDownload ()
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *receivedDataBuffer;
@property (nonatomic, strong) NSFileHandle *file;

@property (nonatomic, strong) NSTimer *speedTimer;
@property (nonatomic, assign) NSInteger expectedDataLength;
@property (nonatomic, assign) NSInteger receivedDataLength;
@property (nonatomic, assign) NSInteger receivedSinceLastTick;
@property (nonatomic, assign) NSTimeInterval startInterval;
@property (nonatomic, assign) NSInteger speed;

@property (nonatomic, copy) FirstResponseBlock firstResponseBlock;
@property (nonatomic, copy) ProgressBlock progressBlock;
@property (nonatomic, copy) ErrorBlock errorBlock;
@property (nonatomic, copy) CompleteBlock completeBlock;
+ (uint64_t)freeDiskSpace;
- (void)updateTransferRate;
- (void)finishOperation;
@end

@implementation TCBlobDownload


#pragma mark - Dealloc


- (void)dealloc
{
    [self.speedTimer invalidate];
}


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
    
    if (![NSURLConnection canHandleRequest:fileRequest]) {
        __autoreleasing NSError *error = [NSError errorWithDomain:kErrorDomain
                                                             code:1
                                                         userInfo:@{ NSLocalizedDescriptionKey:
                                                                     [NSString stringWithFormat:@"Invalid URL provided to TCBlobDownload: %@",
                                                                      fileRequest.URL] }];
        if (self.errorBlock) {
            self.errorBlock(error);
        }
        if ([self.delegate respondsToSelector:@selector(download:didStopWithError:)]) {
            [self.delegate download:self didStopWithError:error];
        }
        
        [self finishOperation];
        
        return;
    }
    
    NSFileManager *fm = [NSFileManager defaultManager];

    if (![fm fileExistsAtPath:self.pathToFile]) {
        [fm createFileAtPath:self.pathToFile
                    contents:nil
                  attributes:nil];
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
        [self.connection scheduleInRunLoop:[NSRunLoop mainRunLoop]
                                   forMode:NSDefaultRunLoopMode];
        [self willChangeValueForKey:@"isExecuting"];
        [self.connection start];
        self.startInterval = [NSDate timeIntervalSinceReferenceDate];
        self.speedTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                           target:self
                                                         selector:@selector(updateTransferRate)
                                                         userInfo:nil
                                                          repeats:YES];
        NSRunLoop* runLoop = [NSRunLoop currentRunLoop];
        [runLoop addTimer:self.speedTimer forMode:NSRunLoopCommonModes];
        [runLoop run];
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
    __autoreleasing NSError *downloadError = [NSError errorWithDomain:kErrorDomain
                                                                 code:4
                                                             userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Download failed for file: %@. Reason: %@",
                                                                                                     self.fileName,
                                                                                                     error.localizedDescription] }];
    if (self.errorBlock) {
        self.errorBlock(downloadError);
    }
    if ([self.delegate respondsToSelector:@selector(download:didStopWithError:)]) {
        [self.delegate download:self didStopWithError:downloadError];
    }
    
    [self cancelDownloadAndRemoveFile:NO];
}

- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse *)response
{
    self.expectedDataLength = [response expectedContentLength];
    NSHTTPURLResponse *httpUrlResponse = (NSHTTPURLResponse *)response;
    
    __autoreleasing NSError *error;
    
    if (httpUrlResponse.statusCode >= 400) {
        error = [NSError errorWithDomain:kErrorDomain
                                    code:2
                                userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:
                                                                       NSLocalizedString(@"HTTP error code %d (%@) ", @"HTTP error code {satus code} ({status code description})"),
                                                                       httpUrlResponse.statusCode,
                                                                       [NSHTTPURLResponse localizedStringForStatusCode:httpUrlResponse.statusCode]],
                                            HTTPErrorCode: @(httpUrlResponse.statusCode) }];
    }
    
    if ([TCBlobDownload freeDiskSpace] < self.expectedDataLength && self.expectedDataLength != -1) {
        error = [NSError errorWithDomain:kErrorDomain
                                    code:3
                                userInfo:@{ NSLocalizedDescriptionKey:NSLocalizedString(@"Not enough free disk space", @"") }];
    }
    
    if (!error) {
        [self.receivedDataBuffer setData:nil];
        
        if (self.firstResponseBlock) {
            self.firstResponseBlock(response);
        }
        if ([self.delegate respondsToSelector:@selector(download:didReceiveFirstResponse:)]) {
            [self.delegate download:self didReceiveFirstResponse:response];
        }
    }
    else {
        if (self.errorBlock) {
            self.errorBlock(error);
        }
        if ([self.delegate respondsToSelector:@selector(download:didStopWithError:)]) {
            [self.delegate download:self didStopWithError:error];
        }
        
        [self cancelDownloadAndRemoveFile:NO];
    }
}

- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData *)data
{
    [self.receivedDataBuffer appendData:data];
    self.receivedDataLength += [data length];
    
    NSLog(@"%d", self.remainingTime);
    TCLog(@"%@ | %.2f%% - Received: %ld - Total: %ld",
          self.fileName, (float) _receivedDataLength / self.expectedDataLength * 100, (long)self.receivedDataLength, (long)self.expectedDataLength);
    
    if (self.receivedDataBuffer.length > kBufferSize && self.file) {
        [self.file writeData:self.receivedDataBuffer];
        [self.receivedDataBuffer setData:nil];
    }
    
    if (self.progressBlock) {
        self.progressBlock(self.receivedDataLength, self.expectedDataLength, self.remainingTime);
    }
    if ([self.delegate respondsToSelector:@selector(download:didReceiveData:onTotal:remainingTime:)]) {
        [self.delegate download:self
                 didReceiveData:self.receivedDataLength
                        onTotal:self.expectedDataLength
                  remainingTime:self.remainingTime];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection*)connection
{
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

- (void)updateTransferRate
{
    self.receivedSinceLastTick = self.receivedDataLength - self.receivedSinceLastTick;
    NSLog(@"received in this tick: %d", self.receivedSinceLastTick);
    self.speed = self.receivedSinceLastTick / ([NSDate timeIntervalSinceReferenceDate] - self.startInterval);
    NSLog(@"speed: %d b/s", self.speed);
}

- (void)finishOperation
{
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    [self.connection cancel];
    [self setConnection:nil];
    [self.file closeFile];
    [self.speedTimer invalidate];
    [self didChangeValueForKey:@"isFinished"];
    [self didChangeValueForKey:@"isExecuting"];
}

- (void)cancelDownloadAndRemoveFile:(BOOL)remove
{
    [self finishOperation];

    NSFileManager *fm = [NSFileManager defaultManager];
    
    if (remove && [fm fileExistsAtPath:self.pathToFile]) {
        __autoreleasing NSError *fileError;
        [fm removeItemAtPath:self.pathToFile error:&fileError];
        if (fileError) {
            TCLog(@"An error occured while removing file - %@", fileError);
            if (self.errorBlock) {
                self.errorBlock(fileError);
            }
            if ([self.delegate respondsToSelector:@selector(download:didStopWithError:)]) {
                [self.delegate download:self didStopWithError:fileError];
            }
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
        // TODO handle error
    }
    return totalFreeSpace;
}


#pragma mark - Custom Getters


- (NSString *)fileName
{
    return [[NSURL URLWithString:[self.downloadURL absoluteString]] lastPathComponent];
}

- (NSString *)pathToFile
{
    return [self.pathToDownloadDirectory stringByAppendingPathComponent:self.fileName];
}

- (NSInteger)remainingTime
{
    if (self.speed > 0)
        return (self.expectedDataLength - self.receivedDataLength) / self.speed;
    else
        return -1;
}

@end
