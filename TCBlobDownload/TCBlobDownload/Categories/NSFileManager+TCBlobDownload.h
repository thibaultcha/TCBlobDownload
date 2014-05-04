//
//  NSFileManager+TCBlobDownload.h
//  TCBlobDownload
//
//  Created by Thibault Charbonnier on 03/05/14.
//  Copyright (c) 2014 thibaultCha. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (TCBlobDownload)
+ (BOOL)createDirFromPath:(NSString *)path error:(NSError *__autoreleasing *)error;
@end
