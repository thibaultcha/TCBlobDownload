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

- (void)testSharedInstance
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
    XCTAssertEqualObjects(self.manager.defaultDownloadPath, NSHomeDirectory(), @"Default download path is not set correctly");
}

- (void)testShouldHandleNilDownloadPath
{
    TCBlobDownloader *download2 = [self.manager startDownloadWithURL:[self fixtureDownloadWithNumberOfBytes:1024]
                                                          customPath:nil
                                                            delegate:nil];
    
    XCTAssertEqualObjects(self.manager.defaultDownloadPath, download2.pathToDownloadDirectory,
                          @"TCBlobDownloadManager did not set defaultPath in startDownloadWithURL:customPath:delegate:");
    
    TCBlobDownloader *download3 = [self.manager startDownloadWithURL:[self fixtureDownloadWithNumberOfBytes:1024]
                                                          customPath:nil
                                                       firstResponse:NULL
                                                            progress:NULL
                                                               error:NULL
                                                            complete:NULL];
    
    XCTAssertEqualObjects(self.manager.defaultDownloadPath, download3.pathToDownloadDirectory,
                          @"TCBlobDownloadManager did not set defaultPath in startDownloadWithURL:customPath:firstResponse:progress:error:complete:");
    
}

- (void)DISABLED_testDownloadCount
{
    for (NSInteger i = 0; i < 50; i++) {
        [self.manager startDownloadWithURL:[self fixtureDownloadWithNumberOfBytes:4096]
                                customPath:nil
                                  delegate:nil];
    }
    
    XCTAssert(self.manager.downloadCount == 100);
}

- (void)DISABLED_testCurrentDownloadCount_and_maxConcurrentDownloads
{
    [self.manager setMaxConcurrentDownloads:1];
    
    for (NSInteger i = 0; i < 50; i++) {
        [self.manager startDownloadWithURL:[self fixtureDownloadWithNumberOfBytes:4096]
                                customPath:nil
                                  delegate:nil];
    }
    
    [self waitForCondition:self.manager.currentDownloadsCount > 0];
    
    XCTAssertEqual(1, self.manager.currentDownloadsCount, @"Maximum number of downloads is not respected.");
}

- (void)DISABLED_testAllOperationsCorrectlyCancelled
{
    for (NSInteger i = 0; i < 50; i++) {
        [self.manager startDownloadWithURL:[self fixtureDownloadWithNumberOfBytes:4096]
                                customPath:nil
                                  delegate:nil];
    }
    
    [self waitForCondition:self.manager.downloadCount > 0];
    
    [self.manager cancelAllDownloadsAndRemoveFiles:YES];
    
    [self waitForCondition:self.manager.downloadCount == 0];
    
    XCTAssertEqual(0, self.manager.downloadCount, @"TCBlobDownloadManager cancelAllDownloadsAndRemoveFiles: did not properly finish all its operations.");
}

@end
