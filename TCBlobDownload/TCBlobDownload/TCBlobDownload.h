//
//  TCBlobDownload.h
//
//  Created by Thibault Charbonnier on 15/04/13.
//  Copyright (c) 2013 Thibault Charbonnier. All rights reserved.
//

#define BUFFER_SIZE 1024*1024 // 1 MB
#define DEFAULT_TIMEOUT 30
#define ERROR_DOMAIN @"myDomain"

#import <Foundation/Foundation.h>

typedef void (^FirstResponseBlock)(NSURLResponse *response);
typedef void (^ProgressBlock)(float receivedLength, float totalLength);
typedef void (^ErrorBlock)(NSError *error);
typedef void (^DownloadCanceledBlock)(BOOL fileRemoved);
typedef void (^DownloadFinishedBlock)(NSString *pathToFile);

@protocol TCBlobDownloadDelegate;

@interface TCBlobDownload : NSOperation <NSURLConnectionDelegate>

@property (nonatomic, assign) id<TCBlobDownloadDelegate> delegate;
@property (nonatomic, copy) NSURL *urlAdress;
@property (nonatomic, copy) NSString *pathToDownloadDirectory;
@property (nonatomic, retain) NSString *fileName;

/**
* Init. Will not start the download while you do not add the instanciated object to
* TCBlobDownloadManager. pathToDL cannot be nil from here.
*/
- (id)initWithUrl:(NSURL *)url
     downloadPath:(NSString *)pathToDL
      andDelegate:(id<TCBlobDownloadDelegate>)delegateOrNil;

/**
* Same but with completion blocks
*/
- (id)initWithUrl:(NSURL *)url
     downloadPath:(NSString *)pathToDL
firstResponseBlock:(FirstResponseBlock)firstResponseBlock
    progressBlock:(ProgressBlock)progressBlock
       errorBlock:(ErrorBlock)errorBlock
downloadCanceledBlock:(DownloadCanceledBlock)downloadCanceledBlock
downloadFinishedBlock:(DownloadFinishedBlock)downloadFinishedBlock;

/**
* Cancel a download and remove the file if specified.
*/
- (void)cancelDownloadAndRemoveFile:(BOOL)remove;

/**
* Make the receiver download dependent of the given download
*/
- (void)addDependentDownload:(TCBlobDownload *)blobDownload;

/**
* Create a path from given string. You should not use this method directly.
*/
+ (BOOL)createPathFromPath:(NSString *)path;

@end

@protocol TCBlobDownloadDelegate <NSObject>

@optional

/**
* Received first response
*/
- (void)download:(TCBlobDownload *)blobDownload didReceiveFirstResponse:(NSURLResponse *)response;

/**
* Let you handle the error for a given download
*/
- (void)download:(TCBlobDownload *)blobDownload didStopWithError:(NSError *)error;

/**
* Called when download is canceled
*/
- (void)download:(TCBlobDownload *)blobDownload didCancelRemovingFile:(BOOL)fileRemoved;

/**
* On each response from the NSURLConnection
*/
- (void)download:(TCBlobDownload *)blobDownload
  didReceiveData:(uint64_t)receivedLength
         onTotal:(uint64_t)totalLength;

/**
* When a download ends
*/
- (void)downloadDidFinishWithDownload:(TCBlobDownload *)blobDownload;

@end
