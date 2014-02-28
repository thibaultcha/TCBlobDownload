//
//  TCBlobDownload.h
//
//  Created by Thibault Charbonnier on 15/04/13.
//  Copyright (c) 2013 Thibault Charbonnier. All rights reserved.
//

#define NO_LOG
#if defined(DEBUG) && !defined(NO_LOG)
    #define TCLog(format, ...) NSLog(format, ## __VA_ARGS__)
#else
    #define TCLog(format, ...)
#endif

#import <Foundation/Foundation.h>

extern NSString * const HTTPErrorCode;

typedef void (^FirstResponseBlock)(NSURLResponse *response);
typedef void (^ProgressBlock)(float receivedLength, float totalLength, NSInteger remainingTime);
typedef void (^ErrorBlock)(NSError *);
typedef void (^CompleteBlock)(BOOL downloadFinished, NSString *pathToFile);

@protocol TCBlobDownloadDelegate;


#pragma mark - TCBlobDownload

/**
 `TCBlobDownload` is a subclass of Cocoa's `NSOperation`. It's purpose is to be executed by the `TCBlobDownloadManager` singleton to download large files in background threads.
 
 Each `TCBlobDownload` instance will run in a background thread and will download files via an `NSURLConnection`. Each `TCBlobDownload` can depend (or not) of a `TCBlobDownloadDelegate` or use blocks to notify your UI from its status.
 
 @see TCBlobDownloadDelegate protocol
 */
@interface TCBlobDownload : NSOperation <NSURLConnectionDelegate>

/**
 The delegate property of a `TCBlobDownload` instance. Can be `nil`.
 */
@property (nonatomic, unsafe_unretained) id<TCBlobDownloadDelegate> delegate;

/**
 The directory where to download the file.
 
 @warning You should not set this property directly as it is managed in the initialization method.
 */
@property (nonatomic, copy) NSString *pathToDownloadDirectory;

/**
 The path to the downloaded file, including the file name.
 
 @warning You should not set this property directly as the file name is managed by the library.
 */
@property (nonatomic, copy, readonly) NSString *pathToFile;

/**
 The URL of the file to download.
 
 @warning You should not set this property directly, as it is managed by the initialization method.
 */
@property (nonatomic, copy, readonly) NSURL *downloadURL;

/**
 The file name, based on the last path component of the download URL.
 
 ## Note
 
 You cannot change the file name during the download process. The file name of a file downloaded by TCBlobDownload is the last part of the URL used to download it. This allow TCBlobDownload to check if a part of that file has already been downloaded and if so, retrieve the downloaded from where it has previously stopped. It is up to you to manage your download paths to avoid downloading 2 files with the same name.

 You can change the file name once the file has been downloaded in the completion block or the appropriate delegate method.
 
 @see TCBlobDownloadDelegate protocol
 
 @warning You should not set this property directly, as it is retrieved from the download URL.
 */
@property (nonatomic, copy, readonly) NSString *fileName;

/**
 The current speed of the download in bits/sec. This property updates itself regularly so you can retrieve it on a regular interval to update your UI.
 */
@property (nonatomic, assign, readonly) NSInteger speedRate;

/**
 The estimated number of seconds before the download completes.
 
 `-1` if the remaining time has not been calculated yet.
 */
@property (nonatomic, assign, readonly) NSInteger remainingTime;

/**
 Instanciates a `TCBlobDownload` object with delegate. `TCBlobDownload` objects instanciated this way will not be executed until they are passed to the `TCBlobDownloadManager` singleton.
 
 @see startDownload:
 
 @param url  The URL from where to download the file.
 @param pathToDLOrNil  An optional path to override the default download path of the `TCBlobDownloadManager` instance. Can be `nil`.
 @param delegateOrNil  An optional delegate. Can be `nil`.
 @return The newly created `TCBlobDownload`.
 */
- (instancetype)initWithURL:(NSURL *)url
               downloadPath:(NSString *)pathToDLOrNil
                   delegate:(id<TCBlobDownloadDelegate>)delegateOrNil;

/**
 Instanciates a `TCBlobDownload` object with response blocks. `TCBlobDownload` objects instanciated this way will not be executed until they are passed to the `TCBlobDownloadManager` singleton.
 
 @see startDownload:
 
 @param url  The URL of the file to download.
 @param customPathOrNil  An optional path to override the default download path of the `TCBlobDownloadManager` instance. Can be `nil`.
 @param firstResponseBlock  This block is called when receiving the first response from the server. Can be `nil`.
 @param progressBlock  This block is called on each response from the server while the download is occurring. Can be `nil`.
 @param errorBlock  Called when an error occur during the download. If this block is called, the download will be cancelled just after. Can be `nil`.
 @param completeBlock  Called when the download is completed. Can be `nil`.
 @return The newly created `TCBlobDownload`.
 */
- (instancetype)initWithURL:(NSURL *)url
               downloadPath:(NSString *)pathToDL
              firstResponse:(FirstResponseBlock)firstResponseBlock
                   progress:(ProgressBlock)progressBlock
                      error:(ErrorBlock)errorBlock
                   complete:(CompleteBlock)completeBlock;

/**
 Cancels the download. Remove already downloaded parts of the file from the disk is asked.
 
 @param remove  If `YES`, this method will remove the downloaded file parts from the disk. File parts are left untouched if set to `NO`. This will allow TCBlobDownload to restart the download from where it has ended in a future operation.
 */
- (void)cancelDownloadAndRemoveFile:(BOOL)remove;

/**
 Makes the receiver download dependent of the given download. The receiver download will not execute itself until the given download has finished.
 
 @param blobDownload  The download on which to depend.
 */
- (void)addDependentDownload:(TCBlobDownload *)blobDownload;

@end


#pragma mark - TCBlobDownload Delegate

/**
 The `TCBlobDownloadDelegate` protocol defines the methods supported by `TCBlobDownload` to notify you of the state of the download.
 */
@protocol TCBlobDownloadDelegate <NSObject>
@optional
/**
 Optional. Called when the `TCBlobDownload` object has received the first response from the server.
 
 @param blobDownload  The `TCBlobDownload` object receiving the first response.
 @param response  The `NSURLResponse` from the server.
 */
- (void)download:(TCBlobDownload *)blobDownload didReceiveFirstResponse:(NSURLResponse *)response;

/**
 Optional. Called on each response from the server while the download is occurring.
 
 @param blobDownload  The `TCBlobDownload` object which received data.
 @param receivedLength  The total number of already received bytes.
 @param totalLength  The total number of bytes of the file.
 
 ## Note
 
 If you pause and restart later a download, the new `TCBlobDownload` will resume it from where it has stopped (see `fileName` property for more explanations). Therefore, you might want to track yourself the total size of the file when you first tried to download it, otherwise the `totalLength` is the actual remaining length to download and might not suit your needs if you do something such as a progress bar.
 */
- (void)download:(TCBlobDownload *)blobDownload
  didReceiveData:(uint64_t)receivedLength
         onTotal:(uint64_t)totalLength;

/**
 Optional. Called when an error occur during the download. If this method is called, the `TCBlobDownload` will be automatically cancelled just after, without deleting the the already downloaded parts of the file. This is done by calling `cancelDownloadAndRemoveFile:`
 
 @see cancelDownloadAndRemoveFile:
 
 @param blobDownload  The `TCBlobDownload` object which trigerred an error.
 @param error  The trigerred error.
 */
- (void)download:(TCBlobDownload *)blobDownload
didStopWithError:(__autoreleasing NSError **)error;

/**
 Optional. Called when the `TCBlobDownload` will be removed from the `TCBlobDownloadManager` singleton.
 
 @param blobDownload  The `TCBlobDownload` object whose execution is finished.
 @param downloadFinished  `YES` if the file has been downloaded, `NO` if not.
 @param pathToFile  The path where the file has been downloaded.
 */
- (void)download:(TCBlobDownload *)blobDownload
didFinishWithSucces:(BOOL)downloadFinished
          atPath:(NSString *)pathToFile;

@end
