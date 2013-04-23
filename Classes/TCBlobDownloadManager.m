//
//  BlobDownloadManager.m
//
//  Created by Thibault Charbonnier on 16/04/13.
//  Copyright (c) 2013 Thibault Charbonnier. All rights reserved.
//

#import "TCBlobDownloadManager.h"

@interface TCBlobDownloadManager ()
{
    NSOperationQueue *_operationQueue;
}

@end

@implementation TCBlobDownloadManager


#pragma mark - Init and utilities


- (id)init
{
    if (self = [super init]) {
        _operationQueue = [[NSOperationQueue alloc] init];
        _defaultDownloadPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/"];
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

- (void)setDefaultDownloadDirectory:(NSString *)pathToDL
{
    NSFileManager *fm = [NSFileManager defaultManager];
    
    if ([fm fileExistsAtPath:pathToDL]) {
        self.defaultDownloadPath = pathToDL;
    } else {
        NSError *error = nil;
        BOOL created = [fm createDirectoryAtPath:pathToDL
                     withIntermediateDirectories:YES
                                      attributes:nil
                                           error:&error];
        if (created) 
            self.defaultDownloadPath = pathToDL;
        else
#ifdef DEBUG
            NSLog(@"Error creating download directory - %@ %d",
                  [error localizedDescription],
                  [error code]);
#endif
    }
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


- (void)addDownloadWithURL:(NSString *)urlString
   customDownloadDirectory:(NSString *)customPath
               andDelegate:(id<TCBlobDownloadDelegate>)delegateOrNil
{
    NSString *downlodPath = self.defaultDownloadPath;
    if (nil != customPath)
        downlodPath = customPath;
    
    TCBlobDownload *downloader = [[TCBlobDownload alloc] initWithUrlString:urlString
                                                              downloadPath:downlodPath
                                                               andDelegate:delegateOrNil];
    [_operationQueue addOperation:downloader];
}

- (void)addDownload:(TCBlobDownload *)blobDownload
{
    [_operationQueue addOperation:blobDownload];
}

- (void)cancelAllDownloadsAndRemoveFiles:(BOOL)remove
{
    for (TCBlobDownload *blob in [_operationQueue operations])
        [blob endDownloadAndRemoveFile:remove];
#ifdef DEBUG
    NSLog(@"Cancelled all downloads.");
#endif
}

@end
