//
//  BlobDownloadManager.h
//
//  Created by Thibault Charbonnier on 16/04/13.
//  Copyright (c) 2013 Thibault Charbonnier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BlobDownloader.h"

@interface BlobDownloadManager : NSObject

@property (retain, nonatomic) NSString *defaultDownloadPath;

//
// Retrieve the singleton
//
+ (id)sharedDownloadManager;
//
// Add a download with the specified URL, an optional download path (default if nil)
// and an optional delegate.
// (if you want to update your view, your delegate should be the ViewController
// and you should find a way to store the returned value for later retrieve)
//
// The download will be added to a NSOperationQueue and will run in background.
//
- (BlobDownloader *)addDownloadWithURL:(NSString *)urlString
               customDownloadDirectory:(NSString *)customPath
                           andDelegate:(id<BlobDownloadManagerDelegate>)delegateOrNil;
//
// Specify the download repository. It can be a non existant path.
//
- (void)setDefaultDownloadDirectory:(NSString *)pathToDL;
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
