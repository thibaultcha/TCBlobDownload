//
//  MediaServer.h
//  Naveo
//
//  Created by Thibault Charbonnier on 16/04/13.
//  Copyright (c) 2013 Thibault Charbonnier. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BlobDownloaderQueue : NSObject

@property (strong, nonatomic) NSOperationQueue *operationQueue;

+ (id)sharedDownloadQueue;

@end
