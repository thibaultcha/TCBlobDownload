//
//  NSFileManager+TCBlobDownload.m
//  TCBlobDownload
//
//  Created by Thibault Charbonnier on 03/05/14.
//  Copyright (c) 2014 thibaultCha. All rights reserved.
//

#import "NSFileManager+TCBlobDownload.h"

@implementation NSFileManager (TCBlobDownload)

+ (BOOL)createDirFromPath:(NSString *)path error:(NSError *__autoreleasing *)error
{
    if (path == nil || [path isEqualToString:@""]) {
        return NO;
    }
    
    return [[NSFileManager defaultManager] createDirectoryAtPath:path
                                     withIntermediateDirectories:YES
                                                      attributes:nil
                                                           error:error];
}

@end
