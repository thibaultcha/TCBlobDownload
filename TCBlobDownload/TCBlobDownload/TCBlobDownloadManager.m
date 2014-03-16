//
//  TCBlobDownloadManager.m
//
//  Created by Thibault Charbonnier on 16/04/13.
//  Copyright (c) 2013 Thibault Charbonnier. All rights reserved.
//

#import "TCBlobDownloadManager.h"

@interface TCBlobDownloadManager ()
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@end

@implementation TCBlobDownloadManager
@dynamic downloadCount;


#pragma mark - Init


- (id)init
{
    self = [super init];
    if (self) {
        _operationQueue = [[NSOperationQueue alloc] init];
        _defaultDownloadPath = [NSString stringWithString:NSTemporaryDirectory()];
    }
    return self;
}

+ (id)sharedDownloadManager
{
    static dispatch_once_t onceToken;
    static id sharedManager = nil;
    
    dispatch_once(&onceToken, ^{
        sharedManager = [[[self class] alloc] init];
    });
    return sharedManager;
}


#pragma mark - Utilities


- (void)setDefaultDownloadPath:(NSString *)pathToDL
{
    if ([TCBlobDownloadManager createPathFromPath:pathToDL]) {
        _defaultDownloadPath = pathToDL;
    }
}

- (void)setMaxConcurrentDownloads:(NSInteger)maxConcurrent
{
    [self.operationQueue setMaxConcurrentOperationCount:maxConcurrent];
}


#pragma mark - Getters


- (NSUInteger)downloadCount
{
    return [_operationQueue operationCount];
}


#pragma mark - TCBlobDownloads Management


- (TCBlobDownload *)startDownloadWithURL:(NSURL *)url
                              customPath:(NSString *)customPathOrNil
                                delegate:(id<TCBlobDownloadDelegate>)delegateOrNil
{
    NSString *downloadPath = self.defaultDownloadPath;
    if ([TCBlobDownloadManager createPathFromPath:customPathOrNil]) {
        downloadPath = customPathOrNil;
    }
    
    TCBlobDownload *downloader = [[TCBlobDownload alloc] initWithURL:url
                                                        downloadPath:downloadPath
                                                            delegate:delegateOrNil];
    [_operationQueue addOperation:downloader];
    
    return downloader;
}

- (TCBlobDownload *)startDownloadWithURL:(NSURL *)url
                              customPath:(NSString *)customPathOrNil
                           firstResponse:(FirstResponseBlock)firstResponseBlock
                                progress:(ProgressBlock)progressBlock
                                   error:(ErrorBlock)errorBlock
                                complete:(CompleteBlock)completeBlock
{
    NSString *downloadPath = self.defaultDownloadPath;
    if ([TCBlobDownloadManager createPathFromPath:customPathOrNil]) {
        downloadPath = customPathOrNil;
    }
    
    TCBlobDownload *downloader = [[TCBlobDownload alloc] initWithURL:url
                                                        downloadPath:downloadPath
                                                       firstResponse:firstResponseBlock
                                                            progress:progressBlock
                                                               error:errorBlock
                                                            complete:completeBlock];
    [self.operationQueue addOperation:downloader];
    
    return downloader;
}

- (void)startDownload:(TCBlobDownload *)download
{
    if (download.pathToDownloadDirectory == nil) {
        download.pathToDownloadDirectory = self.defaultDownloadPath;
    }
    [self.operationQueue addOperation:download];
}

- (void)cancelAllDownloadsAndRemoveFiles:(BOOL)remove
{
    for (TCBlobDownload *blob in [self.operationQueue operations]) {
        [blob cancelDownloadAndRemoveFile:remove];
    }
}


#pragma mark - Custom


+ (BOOL)createPathFromPath:(NSString *)path
{
    NSFileManager *fm = [NSFileManager defaultManager];
    
    if (path == nil || [path isEqualToString:@""]) {
        // handle error
        return false;
    }
    
    if ([fm fileExistsAtPath:path]) {
        return true;
    }
    else {
        __autoreleasing NSError *error;
        BOOL created = [fm createDirectoryAtPath:path
                     withIntermediateDirectories:YES
                                      attributes:nil
                                           error:&error];
        if (error) {
            TCLog(@"Error creating download directory %@ - %@", path, error);
            // TODO handle error
        }
        return created;
    }
}

@end
