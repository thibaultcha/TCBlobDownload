//
//  TCBlobDownloadSettings.m
//  TCBlobDownload
//
//  Created by Thibault Charbonnier on 10/07/13.
//  Copyright (c) 2013 thibaultCha. All rights reserved.
//

#import "TCBlobDownloadSettings.h"

@implementation TCBlobDownloadSettings


#pragma mark - Init


- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

+ (id)sharedSettings
{
    static dispatch_once_t onceToken;
    static TCBlobDownloadSettings *sharedInstance = nil;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[[self class] alloc] init];
        [sharedInstance setDownloadPath:NSTemporaryDirectory()];
        [sharedInstance setLogLevel:0];
    });
    
    return sharedInstance;
}

@end
