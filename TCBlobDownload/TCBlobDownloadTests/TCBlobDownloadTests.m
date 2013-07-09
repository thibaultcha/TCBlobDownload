//
//  TCBlobDownloadTests.m
//  TCBlobDownloadTests
//
//  Created by Thibault Charbonnier on 09/07/13.
//  Copyright (c) 2013 thibaultCha. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TCBlobDownloadManager.h"

static NSString * const kValidURLToDownload = @"https://github.com/thibaultCha/TCBlobDownload/archive/master.zip";

@interface TCBlobDownloadTests : XCTestCase
@property (nonatomic, unsafe_unretained) TCBlobDownloadManager *manager;
@end

@implementation TCBlobDownloadTests

- (void)setUp
{
    [super setUp];
    
    _manager = [TCBlobDownloadManager sharedDownloadManager];
}

- (void)tearDown
{
    [super tearDown];
}


#pragma mark - TCBlobDownloadManager


- (void)testSingleton
{
    XCTAssertNotNil(self.manager, @"TCBlobDownloadManager singleton is nil.");
}

- (void)testDefaultDownloadPath
{
    XCTAssertNotNil(self.manager.defaultDownloadPath, @"TCBlobDownloadManager default download path is nil.");
}

- (void)testSetDefaultDownloadPath
{
    NSString *newDefaultDownloadPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"blobdownloads"];
    [self.manager setDefaultDownloadPath:newDefaultDownloadPath];
    XCTAssertTrue([self.manager.defaultDownloadPath isEqualToString:newDefaultDownloadPath],
                  @"Default download path is not set correctly");
}

- (void)testAllOperationsCorrectlyCancelled
{
    for (NSInteger i=0 ; i < 5 ; i++) {
        [self.manager startDownloadWithURL:[NSURL URLWithString:kValidURLToDownload]
                                customPath:nil
                               andDelegate:nil];
    }
    [self.manager cancelAllDownloadsAndRemoveFiles:YES];
    XCTAssertTrue(self.manager.downloadCount == 0,
                  @"TCBlobDownloadManager cancelAllDownload did not properly finished all operations.");
}


#pragma mark - TCBlobDownload


- (void)testOperationCorrectlyCancelled
{
    TCBlobDownload *download = [[TCBlobDownload alloc]initWithUrl:[NSURL URLWithString:kValidURLToDownload]
                                                     downloadPath:self.manager.defaultDownloadPath
                                                      andDelegate:nil];
    [self.manager startDownload:download];
    [download cancelDownloadAndRemoveFile:YES];
    XCTAssertTrue(self.manager.downloadCount == 0,
                  @"Operation TCBlobDownload did not finished properly.");
}

@end
