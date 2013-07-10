//
//  TCBlobDownloadSettings.h
//  TCBlobDownload
//
//  Created by Thibault Charbonnier on 10/07/13.
//  Copyright (c) 2013 thibaultCha. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCBlobDownloadSettings : NSObject

@property (nonatomic, copy) NSString *downloadPath;
@property (nonatomic) NSInteger logLevel;

+ (id)sharedSettings;

@end
