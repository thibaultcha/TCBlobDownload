//
//  MediaServer.m
//  Naveo
//
//  Created by Thibault Charbonnier on 16/04/13.
//  Copyright (c) 2013 Thibault Charbonnier. All rights reserved.
//

#import "BlobDownloaderQueue.h"

@implementation BlobDownloaderQueue

- (id)init
{
    if (self = [super init]) {
        _operationQueue = [[NSOperationQueue alloc] init];
    }
    
    return self;
}

+ (id)sharedDownloadQueue
{
    static dispatch_once_t onceToken;
    static id sharedMediaServer = nil;
    
    dispatch_once(&onceToken, ^{
        sharedMediaServer = [[[self class] alloc] init];
    });
    
    return sharedMediaServer;
}

@end
