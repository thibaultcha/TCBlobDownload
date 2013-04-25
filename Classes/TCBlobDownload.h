//
//  TCBlobDownload.h
//
//  Created by Thibault Charbonnier on 15/04/13.
//  Copyright (c) 2013 Thibault Charbonnier. All rights reserved.
//

#define BUFFER_SIZE 1024*1024 // 1 MB
#define DEFAULT_TIMEOUT 10
#define ERROR_DOMAIN @"myDomain"

#import <Foundation/Foundation.h>

@protocol TCBlobDownloadDelegate;

@interface TCBlobDownload : NSOperation <NSURLConnectionDelegate>

@property (nonatomic, assign) id<TCBlobDownloadDelegate> delegate;
@property (nonatomic, copy) NSURL *urlAdress;
@property (nonatomic, copy) NSString *pathToDownloadDirectory;
@property (nonatomic, retain) NSString *fileName;

//
// Init
//
- (id)initWithUrlString:(NSString *)urlString
           downloadPath:(NSString *)pathToDL
            andDelegate:(id<TCBlobDownloadDelegate>)delegateOrNil;

//
// Cancel a download and remove the file if specified.
//
- (void)cancelDownloadAndRemoveFile:(BOOL)remove;

//
// Create a path from string
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
// If you stored the BlobDownloader you can retrieve it and update the corresponding view
//
- (void)download:(TCBlobDownload *)blobDownload
  didReceiveData:(uint64_t)received
         onTotal:(uint64_t)total;

//
// If you stored the BlobDownloader you can retrieve it and update the corresponding view
//
- (void)downloadDidFinishWithDownload:(TCBlobDownload *)blobDownload;

@end
