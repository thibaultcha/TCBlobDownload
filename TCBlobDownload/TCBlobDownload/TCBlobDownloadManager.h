//
//  TCBlobDownloadManager.h
//
//  Created by Thibault Charbonnier on 16/04/13.
//  Copyright (c) 2013 Thibault Charbonnier. All rights reserved.
//

#import "TCBlobDownload.h"

@interface TCBlobDownloadManager : NSObject

@property (nonatomic, strong, setter = setDefaultDownloadPath:) NSString *defaultDownloadPath;
@property (nonatomic, getter = downloadCount) NSUInteger downloadCount;

/**
 Retrieve the singleton
*/
+ (id)sharedDownloadManager;

/**
 Start a download with the specified URL, an optional download path (default if nil)
 and an optional delegate.
 
 The download will be added to an NSOperationQueue and will run in background.
*/
- (TCBlobDownload *)startDownloadWithURL:(NSURL *)url
                              customPath:(NSString *)customPathOrNil
                                delegate:(id<TCBlobDownloadDelegate>)delegateOrNil;

/**
 Same but with completion blocks
*/
- (TCBlobDownload *)startDownloadWithURL:(NSURL *)url
                              customPath:(NSString *)customPathOrNil
                           firstResponse:(FirstResponseBlock)firstResponseBlock
                                progress:(ProgressBlock)progressBlock
                                   error:(ErrorBlock)errorBlock
                                complete:(CompleteBlock)completeBlock;
/**
 Start an already initialized TCBlobDownload
*/
- (void)startDownload:(TCBlobDownload *)download;

/**
 Specify the default download repository. It can be a non existant path,
 if so, it will be created.
*/
- (void)setDefaultDownloadPath:(NSString *)pathToDL;

/**
 Set the maximum concurrent downloads allowed.
*/
- (void)setMaxConcurrentDownloads:(NSInteger)max;

/**
 Return the number of downloads currently in progress.
*/
- (NSUInteger)downloadCount;

/**
 Cancel all downloads.
*/
- (void)cancelAllDownloadsAndRemoveFiles:(BOOL)remove;

/**
 Create a path from given string. You should not use this method directly.
 */
+ (BOOL)createPathFromPath:(NSString *)path;

@end
