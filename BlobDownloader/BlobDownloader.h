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

@protocol BlobDownloaderDelegate;

@interface BlobDownloader : NSOperation <NSURLConnectionDelegate>

@property (nonatomic, assign) id<BlobDownloaderDelegate> delegate;
@property (nonatomic, copy) NSURL *urlAdress;

- (id)initWithUrlString:(NSString *)url andDelegate:(id<BlobDownloaderDelegate>)delegate;

@end


@protocol BlobDownloaderDelegate <NSObject>

@optional
- (void)downloaderDidFinishLoading;
- (void)downloaderDidFailWithError:(NSError **)error;
- (void)downloaderDidReceiveData:(uint64_t)received onTotal:(uint64_t)total;

@end
