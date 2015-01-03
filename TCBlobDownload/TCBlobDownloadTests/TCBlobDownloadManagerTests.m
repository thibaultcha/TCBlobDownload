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
    XCTAssertEqualObjects(m1, m2, @"sharedDownloadManager is not a singleton");
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

- (void)testShouldHandleNilDownloadPath
{
    TCBlobDownloader *download2 = [self.manager startDownloadWithURL:self.validURL
                                                          customPath:nil
                                                            delegate:nil];
    XCTAssertEqualObjects(self.manager.defaultDownloadPath, download2.pathToDownloadDirectory,
                          @"TCBlobDownloadManager did not set defaultPath in startDownloadWithURL:customPath:delegate:");
    
    TCBlobDownloader *download3 = [self.manager startDownloadWithURL:self.validURL
                                                          customPath:nil
                                                       firstResponse:NULL
                                                            progress:NULL
                                                               error:NULL
                                                            complete:NULL];
    XCTAssertEqualObjects(self.manager.defaultDownloadPath, download3.pathToDownloadDirectory,
                          @"TCBlobDownloadManager did not set defaultPath in startDownloadWithURL:customPath:firstResponse:progress:error:complete:");
    
}

- (void)testAllOperationsCorrectlyCancelled
{
    [self.manager setMaxConcurrentDownloads:1];
    
    for (NSInteger i = 0; i < 10; i++) {
        [self.manager startDownloadWithURL:self.validURL
                                customPath:nil
                                  delegate:nil];
    }
    
    [self waitForTimeout:5.0];
    
    [self.manager cancelAllDownloadsAndRemoveFiles:YES];
    
    [self waitForTimeout:kDefaultAsyncTimeout];
    
    XCTAssert(self.manager.downloadCount == 0,
              @"TCBlobDownloadManager cancelAllDownloadsAndRemoveFiles: did not properly finished all operations.");
}

/*
- (void)testSetMaxConcurrentDownloads
{
    [self.manager setMaxConcurrentDownloads:3];
    
    for (NSInteger i = 0; i < 5; i++) {
        [self.manager startDownloadWithURL:self.validURL
                                customPath:nil
                                  delegate:nil];
    }
    
    XCTAssertEqual(self.manager.currentDownloadsCount, 3, @"Maximum number of downloads is not respected.");
}
*/
 
@end
