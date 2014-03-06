//
//  TCBlobDownloadManagerTests.m
//  TCBlobDownload
//
//  Created by Thibault Charbonnier on 02/03/2014.
//  Copyright (c) 2014 thibaultCha. All rights reserved.
//

#import "TCBlobDownloadTestsBase.h"

@interface TCBlobDownloadManagerTests : TCBlobDownloadTestsBase
@end

@implementation TCBlobDownloadManagerTests

- (void)testSingleton
{
    TCBlobDownloadManager *manager = [TCBlobDownloadManager sharedInstance];
    XCTAssertNotNil(manager, @"TCBlobDownloadManager shared instance is nil.");
}

- (void)testSharedInstanceReturnsSameSingletonObject
{
    TCBlobDownloadManager *m1 = [TCBlobDownloadManager sharedInstance];
    TCBlobDownloadManager *m2 = [TCBlobDownloadManager sharedInstance];
    XCTAssertEqualObjects(m1, m2, @"sharedDownloadManager didn't return same object twice");
}

- (void)testDefaultDownloadPath
{
    XCTAssertNotNil(self.manager.defaultDownloadPath, @"TCBlobDownloadManager default download path is nil.");
}

- (void)testSetDefaultDownloadPath
{
    [self.manager setDefaultDownloadPath:NSHomeDirectory()];
    XCTAssertEqualObjects(self.manager.defaultDownloadPath, NSHomeDirectory(),
                          @"Default download path is not set correctly");
}

/*
- (void)testcreateDirFromPath
{
    // test if null
    // test if exists
}
*/

- (void)testAllOperationsCorrectlyCancelled
{
    for (NSInteger i = 0; i < 10; i++) {
        [self.manager startDownloadWithURL:self.validURL
                                customPath:nil
                                  delegate:nil];
    }
    
    [self waitForTimeout:kDefaultAsyncTimeout];
    
    [self.manager cancelAllDownloadsAndRemoveFiles:YES];
    XCTAssert(self.manager.downloadCount == 0,
              @"TCBlobDownloadManager cancelAllDownload did not properly finished all operations.");
}

/*
- (void)testSetMaximumNumberOfDownloads
{
    [self.manager setMaxConcurrentDownloads:3];
    
    for (NSInteger i = 0; i < 5; i++) {
        [self.manager startDownloadWithURL:self.validURL
                                customPath:nil
                                  delegate:nil];
    }
    
    XCTAssertEqual(self.manager.downloadCount, 3, @"Maximum number of downloads is not respected.");
}
*/


@end
