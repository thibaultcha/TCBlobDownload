//
//  TCBlobDownloadManager.h
//
//  Created by Thibault Charbonnier on 16/04/13.
//  Copyright (c) 2013 Thibault Charbonnier. All rights reserved.
//

#import "TCBlobDownload.h"

/**
 `TCBlobDownloadManager` is a subclass of `NSOperationQueue` and is used to execute `TCBlobDownload` objects.
 
 It provides methods to start and cancel a download, as well as defining a maximum amount of simultaneous downloads.
 
 ## Note
 
 This class should be used as a singleton using the `sharedInstance` method.
 */
@interface TCBlobDownloadManager : NSObject

/**
 The default download path for a file if no `customPath` property is set at the creation of the `TCBlobDownload` object.
 
 The default value is `/tmp`.
 
 @warning Please be careful of the iOS Data Storage Guidelines about the download path.
 */
@property (nonatomic, strong) NSString *defaultDownloadPath;

/**
 The number of simultaneous active downloads at a given moment.
 */
@property (nonatomic, assign) NSUInteger downloadCount;

/**
 Creates and returns a `TCBlobDownloadManager` object. If the singleton has already been created, it just returns the object.
*/
+ (instancetype)sharedInstance;

/**
 Instanciates and runs instantly a `TCBlobDownloadObject` with the specified URL, an optional customPath and an optional delegate. Runs in background thread the `TCBlobDownload` object (a subclass of `NSOperation`) in the `TCBlobDownloadManager` instance.
 
 This method returns the created `TCBlobDownload` object for further use.
 
 @param url  The URL of the file to download.
 @param customPathOrNil  An optional path to override the default download path of the `TCBlobDownloadManager` instance. Can be `nil`.
 @param delegateOrNil  An optional delegate. Can be `nil`.

 @return The created and already running `TCBlobDownloadObject`.
*/
- (TCBlobDownload *)startDownloadWithURL:(NSURL *)url
                              customPath:(NSString *)customPathOrNil
                                delegate:(id<TCBlobDownloadDelegate>)delegateOrNil;

/**
 Creates and runs instantly a `TCBlobDownload` object.
 
 @see -startDownloadWithURL:customPath:delegate:
 
 Provides the same functionnality than `-startDownloadWithURL:customPath:delegate:` but creates a `TCBlobDownloadObject` using blocks to update your view.
 
 @param url  The URL of the file to download.
 @param customPathOrNil  An optional path to override the default download path of the `TCBlobDownloadManager` instance. Can be `nil`.
 @param firstResponseBlock  This block is called when receiving the first response from the server. Can be `nil`.
 @param progressBlock  This block is called on each response from the server while the download is occurring. Can be `nil`.
 @param errorBlock  Called when an error occur during the download. If this block is called, the download will be cancelled just after. Can be `nil`.
 @param completeBlock  Called when the download is completed. Can be `nil`.
*/
- (TCBlobDownload *)startDownloadWithURL:(NSURL *)url
                              customPath:(NSString *)customPathOrNil
                           firstResponse:(FirstResponseBlock)firstResponseBlock
                                progress:(ProgressBlock)progressBlock
                                   error:(ErrorBlock)errorBlock
                                complete:(CompleteBlock)completeBlock;

/**
 Starts an already instanciated `TCBlobDownload` object.
 
 You can instanciate a `TCBlobDownload` object and instead of executing it directly using `-startDownloadWithURL:customPath:delegate:` or the block equivalent, pass it to this method whenever you're ready.
 
 @param download  A `TCBlobDownload` object.
*/
- (void)startDownload:(TCBlobDownload *)download;

/**
 Specifies the default download path. (which is `/tmp` by default)
 
 The path can be non existant, if so, it will be created.
 
 @param pathToDL  The new default path.
*/
- (void)setDefaultDownloadPath:(NSString *)pathToDL;

/**
 Set the maximum number of concurrent downloads allowed. If more downloads are passed to the `TCBlobDownloadManager` singleton, they will wait for an older one to end before starting.
 
 @param max  The maximum number of downloads.
*/
- (void)setMaxConcurrentDownloads:(NSInteger)max;

/**
 Cancels all downloads. Remove already downloaded parts of the files from the disk is asked.
 
 @param remove  If `YES`, this method will remove all downloaded files parts from the disk. Files parts are left untouched if set to `NO`. This will allow TCBlobDownload to restart the download from where it has ended in a future operation.
*/
- (void)cancelAllDownloadsAndRemoveFiles:(BOOL)remove;

/**
 Creates a path from given string.
 
 @warning You should not use this method directly, as it is automatically called by `TCBlobDownloadManager` and `TCBlobDownload` to create download paths.
 
 @param path  The path to create.
 @return A boolean indicating if the path has been successfully created.
 */
+ (BOOL)createPathFromPath:(NSString *)path;

@end
