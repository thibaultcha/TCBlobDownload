//
//  TCBlobDownloadManager+AutoRetry.m
//  AppChinaBiz
//
//  Created by barryclass on 15/6/25.
//  Copyright (c) 2015年 AppChina. All rights reserved.
//

#import "TCBlobDownloadManager+AutoRetry.h"
#import "ObjcAssociatedObjectHelpers.h"
#import "TCBlobDownload.h"
#import "ACSInstallManager.h"

#pragma clang diagnostic push
#pragma ide diagnostic ignored "OCUnusedMethodInspection"

@implementation TCBlobDownloadManager (AutoRetry)



SYNTHESIZE_ASC_OBJ(__operationsDict, setOperationsDict);
SYNTHESIZE_ASC_OBJ(__retryDelayCalcBlock, setRetryDelayCalcBlock);

- (void)createOperationsDict {
    [self setOperationsDict:[[NSDictionary alloc] init]];
}

- (void)createDelayRetryCalcBlock {
    RetryDelayCalcBlock block = ^int(int totalRetries, int currentRetry, int delayInSecondsSpecified) {
        return delayInSecondsSpecified;
    };
    [self setRetryDelayCalcBlock:block];
}

- (id)retryDelayCalcBlock {
    if (!self.__retryDelayCalcBlock) {
        [self createDelayRetryCalcBlock];
    }
    return self.__retryDelayCalcBlock;
}

- (id)operationsDict {
    if (!self.__operationsDict) {
        [self createOperationsDict];
    }
    return self.__operationsDict;
}




-(TCBlobDownloader *)createWithURL:(NSURL *)url
                     downloadPath:(NSString *)pathToDL
                       appMetaData:(NSDictionary *)appMetaData
                    firstResponse:(void (^)(NSURLResponse *response))firstResponseBlock
                         progress:(void (^)(uint64_t receivedLength, uint64_t totalLength, NSInteger remainingTime, float progress )) progressBlock
                            error:(void (^)(NSError *error))errorBlock
                         complete:(void (^)(BOOL downloadFinished, NSString *pathToFile))completeBlock
                      autoRetryOf:(int)retriesRemaining
                     retryInterval:(int)intervalInSeconds {
    
    void (^retryBlock)(TCBlobDownloader *, NSError *) = ^(TCBlobDownloader *operation, NSError *error) {
        NSMutableDictionary *retryOperationDict = self.operationsDict[url];
        int originalRetryCount = [retryOperationDict[@"originalRetryCount"] intValue];
        int retriesRemainingCount = [retryOperationDict[@"retriesRemainingCount"] intValue];
        if (retriesRemainingCount > 0) {
            
            NSLog(@"AutoRetry: download file failed: %@, retry %d out of %d begining...",
                  
                  error.localizedDescription, originalRetryCount - retriesRemainingCount + 1, originalRetryCount);
            
            TCBlobDownloader *retryOperation = [self createWithURL:url downloadPath:pathToDL appMetaData:appMetaData  firstResponse:firstResponseBlock progress:progressBlock error:errorBlock complete:completeBlock autoRetryOf:retriesRemainingCount - 1 retryInterval:intervalInSeconds];
            
            NSString *downloadKey = [[ACSInstallManager sharedInstance] parseDownloadKeyFromMetaData:appMetaData];
            
            NSDictionary *headers = [NSDictionary dictionaryWithObjectsAndKeys:downloadKey, @"Cookie",nil];
            
            if (nil != headers) {
                
                NSArray *headerKeys = [headers allKeys];
                
                for (NSString *key in headerKeys) {
                    
                    id value = [headers valueForKey:key];
                    
                    [retryOperation.fileRequest setValue:value forHTTPHeaderField:key];
                    
                }
                
            }
            
            void (^addRetryOperation)() = ^{
                [self startDownload:retryOperation];
            };
            
            RetryDelayCalcBlock delayCalc = self.retryDelayCalcBlock;
            int intervalToWait = delayCalc(originalRetryCount, retriesRemainingCount, intervalInSeconds);
            
            
            if (intervalToWait > 0) {
                NSLog(@"AutoRetry: Delaying retry for downloadinh  %d seconds...", intervalToWait);
                dispatch_time_t delay = dispatch_time(0, (int64_t) (intervalToWait * NSEC_PER_SEC));
                dispatch_after(delay, dispatch_get_main_queue(), ^(void) {
                    addRetryOperation();
                });
            } else {
                addRetryOperation();
            }
        } else {
            NSLog(@"AutoRetry: Request failed %d times: %@", originalRetryCount, error.localizedDescription);
            NSLog(@"AutoRetry: No more retries allowed! executing supplied failure block...");
            errorBlock(error);
            NSLog(@"AutoRetry: done.");
        }
    };
    NSMutableDictionary *operationDict = self.operationsDict[url];
    if (!operationDict) {
        operationDict = [NSMutableDictionary new];
        operationDict[@"originalRetryCount"] = [NSNumber numberWithInt:retriesRemaining];
    }
    operationDict[@"retriesRemainingCount"] = [NSNumber numberWithInt:retriesRemaining];
    NSMutableDictionary *newDict = [NSMutableDictionary dictionaryWithDictionary:self.operationsDict];
    newDict[url] = operationDict;
    self.operationsDict = newDict;
  __block  TCBlobDownloader *operation = [[TCBlobDownloader alloc] initWithURL:url downloadPath:pathToDL firstResponse:firstResponseBlock progress:progressBlock error:^(NSError *error) {
        retryBlock(operation, error);
    } complete:^(BOOL downloadFinished, NSString *pathToFile) {
        NSMutableDictionary *successOperationDict = self.operationsDict[url];
        int originalRetryCount = [successOperationDict[@"originalRetryCount"] intValue];
        int retriesRemainingCount = [successOperationDict[@"retriesRemainingCount"] intValue];
        NSLog(@"AutoRetry: success with %d retries, running success block...", originalRetryCount - retriesRemainingCount);
        completeBlock(downloadFinished, pathToFile);
        NSLog(@"AutoRetry: done.");
    }];
    
    
    NSString *downloadKey = [[ACSInstallManager sharedInstance] parseDownloadKeyFromMetaData:appMetaData];
    
    NSDictionary *headers = [NSDictionary dictionaryWithObjectsAndKeys:downloadKey, @"Cookie",nil];
    
    if (nil != headers) {
        
        NSArray *headerKeys = [headers allKeys];
        
        for (NSString *key in headerKeys) {
            
            id value = [headers valueForKey:key];
            
            [operation.fileRequest setValue:value forHTTPHeaderField:key];
            
        }
        
    }
    
    return operation;
}


@end
