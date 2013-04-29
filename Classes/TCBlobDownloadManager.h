//
//  BlobDownloadManager.h
//
//  Created by Thibault Charbonnier on 16/04/13.
//  Copyright (c) 2013 Thibault Charbonnier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TCBlobDownload.h"

@interface TCBlobDownloadManager : NSObject

@property (retain, nonatomic, setter = setDefaultDownloadPath:) NSString *defaultDownloadPath;

//
// Retrieve the singleton
//
+ (id)sharedDownloadManager;

//
// Start a download with the specified URL, an optional download path (default if nil)
// and an optional delegate.
//
// The download will be added to a NSOperationQueue and will run in background.
//
- (void)startDownloadWithURL:(NSString *)urlString
                  customPath:(NSString *)customPathOrNil
                 andDelegate:(id<TCBlobDownloadDelegate>)delegateOrNil;

//
// Same but with completion blocks
//
- (void)startDownloadWithURL:(NSString *)urlString
                  customPath:(NSString *)customPathOrNil
          firstResponseBlock:(FirstResponseBlock)firstResponseBlock
               progressBlock:(ProgressBlock)progressBlock
                  errorBlock:(ErrorBlock)errorBlock
       downloadFinishedBlock:(DownloadFinishedBlock)downloadFinishedBlock;

//
// Start an already initialized download
//
- (void)startDownload:(TCBlobDownload *)blobDownload;

//
// Specify the default download repository. It can be a non existant path,
// if so, it will be created.
//
- (void)setDefaultDownloadPath:(NSString *)pathToDL;

//
// Set the maximum concurrent downloads allowed.
//
- (void)setMaxConcurrentDownloads:(NSInteger)max;

//
// Return the number of downloads currently in progress.
//
- (NSUInteger)downloadCount;

//
// Cancel all downloads.
//
- (void)cancelAllDownloadsAndRemoveFiles:(BOOL)remove;

@end
