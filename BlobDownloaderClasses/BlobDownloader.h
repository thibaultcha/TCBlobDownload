//
//  BlobDownloader.h
//
//  Created by Thibault Charbonnier on 15/04/13.
//  Copyright (c) 2013 Thibault Charbonnier. All rights reserved.
//

#define BUFFER_SIZE 1024*1024 // 1 MB
#define DEFAULT_TIMEOUT 10
#define ERROR_DOMAIN @"myDomain"

#import <Foundation/Foundation.h>

@protocol BlobDownloadManagerDelegate;

@interface BlobDownloader : NSOperation <NSURLConnectionDelegate>

@property (nonatomic, assign) id<BlobDownloadManagerDelegate> delegate;
@property (nonatomic, copy) NSURL *urlAdress;
@property (nonatomic, copy) NSString *pathToDownloadDirectory;
@property (nonatomic, retain) NSString *fileName;

- (id)initWithUrlString:(NSString *)urlString
           downloadPath: (NSString *)pathToDL
            andDelegate:(id<BlobDownloadManagerDelegate>)delegateOrNil;
//
// Cancel a download and remove the file if specified.
//
- (void)endDownloadAndRemoveFile:(BOOL)remove;

@end

@protocol BlobDownloadManagerDelegate <NSObject>

@optional
//
// Let you handle the error for a given download
//
- (void)downloader:(BlobDownloader *)blobDownloader
  didStopWithError:(NSError *)error;
//
// If you stored the BlobDownloader you can retrieve it and update the corresponding view
//
- (void)downloader:(BlobDownloader *)blobDownloader
    didReceiveData:(uint64_t)received
           onTotal:(uint64_t)total;
//
// If you stored the BlobDownloader you can retrieve it and update the corresponding view
//
- (void)downloadDidFinishWithDownloader:(BlobDownloader *)blobDownloader;

@end
