//
//  TCBlobDownloadTestsBase.h
//  TCBlobDownload
//
//  Created by Thibault Charbonnier on 02/03/2014.
//  Copyright (c) 2014 thibaultCha. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TCBlobDownload.h"

static NSString * const kTestsDirectory = @"com.tcblobdownload.tests";
static NSString * const kHttpbinURL = @"http://httpbin.org";
static NSString * const kValidURLToDownload = @"http://github.com/thibaultCha/TCBlobDownload/archive/master.zip";
static NSString * const kInvalidURLToDownload = @"wait, where?";
static NSString * const k404URLToDownload = @"http://github.com/thibaultCha/TCBlobDownload/archive/totoro";
static const NSTimeInterval kDefaultAsyncTimeout = 2;

typedef NS_ENUM(NSUInteger, kDelegateMethodCalled) {
    kDidFinishWithSuccessMethodCalled = 10,
    kDidStopWithErrorMethodCalled
};

@interface TCBlobDownloadTestsBase : XCTestCase
@property (nonatomic, strong) TCBlobDownloadManager *manager;
@property (nonatomic, copy) NSURL *httpbinURL;
@property (nonatomic, copy) NSURL *validURL;
@property (nonatomic, copy) NSURL *invalidURL;
@property (nonatomic, copy) NSString *testsDirectory;

- (NSURL *)fixtureDownloadWithNumberOfBytes:(NSInteger)bytes;
- (NSURL *)fixtureDownlaodWithStatusCode:(NSInteger)status;

- (void)waitForCondition:(BOOL)condition;
@end
