//
//  TCBlobDownloadManager+AutoRetry.h
//  AppChinaBiz
//
//  Created by barryclass on 15/6/25.
//  Copyright (c) 2015年 AppChina. All rights reserved.
//

#import "TCBlobDownloadManager.h"

typedef int (^RetryDelayCalcBlock)(int, int, int); // int totalRetriesAllowed, int retriesRemaining, int delayBetweenIntervalsModifier


@interface TCBlobDownloadManager (AutoRetry)

-(TCBlobDownloader *)createWithURL:(NSURL *)url
                      downloadPath:(NSString *)pathToDL
                       appMetaData:(NSDictionary *)appMetaData
                     firstResponse:(void (^)(NSURLResponse *response))firstResponseBlock
                          progress:(void (^)(uint64_t receivedLength, uint64_t totalLength, NSInteger remainingTime, float progress )) progressBlock
                             error:(void (^)(NSError *error))errorBlock
                          complete:(void (^)(BOOL downloadFinished, NSString *pathToFile))completeBlock
                       autoRetryOf:(int)retriesRemaining
                     retryInterval:(int)intervalInSeconds;
@end
