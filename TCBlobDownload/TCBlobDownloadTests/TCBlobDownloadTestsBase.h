//
//  TCBlobDownloadTestsBase.h
//  TCBlobDownload
//
//  Created by Thibault Charbonnier on 02/03/2014.
//  Copyright (c) 2014 thibaultCha. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "XCTestCase+AsyncTesting.h"
#import "TCBlobDownload.h"

static NSString * const pathToDownloadTests = @"com.thibaultcha.tcblobdltests";

static NSString * const kValidURLToDownload = @"https://github.com/thibaultCha/TCBlobDownload/archive/master.zip";

static NSString * const kInvalidURLToDownload = @"wait, where?";

static NSString * const k404URLToDownload = @"https://github.com/thibaultCha/TCBlobDownload/archive/totoro";

static const NSTimeInterval kDefaultAsyncTimeout = 2;

typedef NS_OPTIONS(NSUInteger, kDelegateMethodCalled) {
    kDidReceiveFirstResponseMethodCalled = 10,
    kDidReceiveDataMethodCalled,
    kDidFinishWithSuccessMethodCalled,
    kDidStopWithErrorMethodCalled
};

@interface TCBlobDownloadTestsBase : XCTestCase
@property (nonatomic, strong) TCBlobDownloadManager *manager;
@property (nonatomic, copy) NSURL *validURL;
@property (nonatomic, copy) NSURL *invalidURL;
@property (nonatomic, copy) NSString *testsDirectory;
@end
