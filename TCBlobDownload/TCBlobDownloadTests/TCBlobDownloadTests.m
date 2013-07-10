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
@property (nonatomic, strong) NSString *testsDefaultDownloadPath;
@end

@implementation TCBlobDownloadTests

- (void)setUp
{
    [super setUp];
    
    _testsDefaultDownloadPath = [NSTemporaryDirectory() stringByAppendingString:@"tests"];
    
    _manager = [TCBlobDownloadManager sharedDownloadManager];
    [self.manager setDefaultDownloadPath:self.testsDefaultDownloadPath];
}

- (void)tearDown
{
    [self.manager cancelAllDownloadsAndRemoveFiles:YES];
    [self.manager setDefaultDownloadPath:NSTemporaryDirectory()];
    
    [[NSFileManager defaultManager]removeItemAtPath:self.testsDefaultDownloadPath
                                              error:nil];
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
    [download cancelDownloadAndRemoveFile:NO];
    XCTAssertTrue(self.manager.downloadCount == 0,
                  @"Operation TCBlobDownload did not finished properly.");
}

- (void)testFileIsRemovedOnCancel
{
    TCBlobDownload *download = [[TCBlobDownload alloc]initWithUrl:[NSURL URLWithString:kValidURLToDownload]
                                                     downloadPath:self.manager.defaultDownloadPath
                                                      andDelegate:nil];
    [self.manager startDownload:download];
    [download cancelDownloadAndRemoveFile:YES];
    
    NSError *fileError;
    NSArray *content = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:self.manager.defaultDownloadPath
                                                                          error:&fileError];
    if (fileError) {
        XCTFail(@"An error occured while listing files.");
        NSLog(@"%@", fileError);
    }
    if (content.count != 0) {
        XCTFail(@"Files not removed from disk after download cancellation.");
        NSLog(@"%d file(s) located at %@", content.count, self.manager.defaultDownloadPath);
    }
}

@end
