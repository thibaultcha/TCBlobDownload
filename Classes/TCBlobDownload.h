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

@protocol TCBlobDownloadDelegate;

@interface TCBlobDownload : NSOperation <NSURLConnectionDelegate>

@property (nonatomic, assign) id<TCBlobDownloadDelegate> delegate;
@property (nonatomic, copy) NSURL *urlAdress;
@property (nonatomic, copy) NSString *pathToDownloadDirectory;
@property (nonatomic, retain) NSString *fileName;

//
// Init. Will not start the download while you do not add the instanciated object to
// TCBlobDownloadManager. pathToDL cannot be nil from here.
//
- (id)initWithUrlString:(NSString *)urlString
           downloadPath:(NSString *)pathToDL
            andDelegate:(id<TCBlobDownloadDelegate>)delegateOrNil;

//
// Same but with completion blocks
//
- (id)initWithUrlString:(NSString *)urlString
           downloadPath:(NSString *)pathToDL
          progressBlock:(void (^)(float receivedLength, float totalLength))progressBlock
             errorBlock:(void (^)(NSError *error))errorBlock
  downloadFinishedBlock:(void (^)(NSString *pathToFile))downloadFinishedBlock;

//
// Cancel a download and remove the file if specified.
//
- (void)cancelDownloadAndRemoveFile:(BOOL)remove;

//
// Create a path from string. You should not use this method directly.
//
+ (BOOL)createPathFromPath:(NSString *)path;

@end

@protocol TCBlobDownloadDelegate <NSObject>

@optional

//
// Let you handle the error for a given download
//
- (void)download:(TCBlobDownload *)blobDownload
didStopWithError:(NSError *)error;

//
// On each response from the NSURLConnection
//
- (void)download:(TCBlobDownload *)blobDownload
  didReceiveData:(uint64_t)receivedLength
         onTotal:(uint64_t)totalLength;

//
// When a download ends
//
- (void)downloadDidFinishWithDownload:(TCBlobDownload *)blobDownload;

@end
