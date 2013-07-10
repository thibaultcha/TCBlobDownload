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
    [self.manager cancelAllDownloadsAndRemoveFiles:YES];
    [self.manager setDefaultDownloadPath:NSTemporaryDirectory()];
    
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
    [self.manager setDefaultDownloadPath:NSHomeDirectory()];
    XCTAssertTrue([self.manager.defaultDownloadPath isEqualToString:NSHomeDirectory()],
                  @"Default download path is not set correctly");
}

- (void)testAllOperationsCorrectlyCancelled
{
    for (NSInteger i = 0; i < 10; i++) {
        [self.manager startDownloadWithURL:[NSURL URLWithString:kValidURLToDownload]
                                customPath:nil
                               delegate:nil];
    }
    [self.manager cancelAllDownloadsAndRemoveFiles:YES];
    XCTAssertTrue(self.manager.downloadCount == 0,
                  @"TCBlobDownloadManager cancelAllDownload did not properly finished all operations.");
}


#pragma mark - TCBlobDownload


- (void)testOperationCorrectlyCancelled
{
    TCBlobDownload *download = [[TCBlobDownload alloc]initWithURL:[NSURL URLWithString:kValidURLToDownload]
                                                     downloadPath:self.manager.defaultDownloadPath
                                                      delegate:nil];
    [self.manager startDownload:download];
    [download cancelDownloadAndRemoveFile:YES];
    XCTAssertTrue(self.manager.downloadCount == 0,
                  @"Operation TCBlobDownload did not finished properly.");
}

- (void)testFileIsRemovedOnCancel
{
    NSString *customPath = [self.manager.defaultDownloadPath stringByAppendingPathComponent:@"test"];
    
    TCBlobDownload *download = [[TCBlobDownload alloc]initWithURL:[NSURL URLWithString:kValidURLToDownload]
                                                     downloadPath:customPath
                                                         delegate:nil];
    [self.manager startDownload:download];
    [download cancelDownloadAndRemoveFile:YES];
    
    NSError *fileError;
    NSArray *content = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:customPath
                                                                          error:&fileError];
    if (fileError) {
        XCTFail(@"An error occured while listing files.");
        NSLog(@"%@", fileError);
    }
    if (content.count != 0) {
        XCTFail(@"Files not removed from disk after download cancellation.");
        NSLog(@"%d file(s) located at %@", content.count, customPath);
    }
    
    [[NSFileManager defaultManager] removeItemAtPath:customPath error:&fileError];
    if (fileError) {
        XCTFail(@"Cannot delete test directory.");
        NSLog(@"%@", fileError);
    }
}

@end
