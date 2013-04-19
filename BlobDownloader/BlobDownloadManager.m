//
//  BlobDownloadManager.m
//
//  Created by Thibault Charbonnier on 16/04/13.
//  Copyright (c) 2013 Thibault Charbonnier. All rights reserved.
//

#import "BlobDownloadManager.h"

@interface BlobDownloadManager ()
{
    NSOperationQueue *_operationQueue;
}

@end

@implementation BlobDownloadManager


#pragma mark - Init and utilities


- (id)init
{
    if (self = [super init]) {
        _operationQueue = [[NSOperationQueue alloc] init];
    }
    
    return self;
}

+ (id)sharedDownloadManager
{
    static dispatch_once_t onceToken;
    static id sharedMediaServer = nil;
    
    dispatch_once(&onceToken, ^{
        sharedMediaServer = [[[self class] alloc] init];
    });
    
    return sharedMediaServer;
}

- (NSUInteger)downloadCount
{
    return [_operationQueue operationCount];
}

- (void)setMaxConcurrentDownloads:(NSInteger)maxConcurrent
{
    [_operationQueue setMaxConcurrentOperationCount:maxConcurrent];
}


#pragma mark - Downloads Management


- (BlobDownloader *)addDownloadWithURL:(NSString *)urlString
                           andDelegate:(id<BlobDownloadManagerDelegate>)delegateOrNil
{
    BlobDownloader *downloader = [[BlobDownloader alloc] initWithUrlString:urlString
                                                               andDelegate:delegateOrNil];
    [_operationQueue addOperation:downloader];
    
    return downloader;
}

- (void)cancelAllDownloadsAndRemoveFiles:(BOOL)remove
{
    for (BlobDownloader *blob in [_operationQueue operations]) {
        [blob endDownloadAndRemoveFile:remove];
    }
#ifdef DEBUG
    NSLog(@"Cancelled all downloads.");
#endif
}

@end
