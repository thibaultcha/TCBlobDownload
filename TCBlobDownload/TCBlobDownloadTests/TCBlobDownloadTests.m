//
//  TCBlobDownloadTests.m
//  TCBlobDownloadTests
//
//  Created by Thibault Charbonnier on 09/07/13.
//  Copyright (c) 2013 thibaultCha. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TCBlobDownloadManager.h"

static NSString * const pathToDownloadTests = @"com.thibaultcha.tcblobdl";
static NSString * const kValidURLToDownload = @"https://github.com/thibaultCha/TCBlobDownload/archive/master.zip";

@interface TCBlobDownloadTests : XCTestCase
@property (nonatomic, strong) TCBlobDownloadManager *manager;
@end

@implementation TCBlobDownloadTests

- (void)setUp
{
    [super setUp];
    
    _manager = [[TCBlobDownloadManager alloc] init];
    
    __autoreleasing NSError *error;
    [[NSFileManager defaultManager] createDirectoryAtPath:[NSString pathWithComponents:@[NSTemporaryDirectory(), pathToDownloadTests]]
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:&error];
    if (error) {
        XCTFail(@"Error while creating tests directory");
        NSLog(@"Error : %d - %@", error.code, error.localizedDescription);
    }
    
    [self.manager setDefaultDownloadPath:[NSString pathWithComponents:@[NSTemporaryDirectory(), pathToDownloadTests]]];
}

- (void)tearDown
{
    self.manager = nil;
    

    __autoreleasing NSError *error;
    [[NSFileManager defaultManager]removeItemAtPath:[NSString pathWithComponents:@[NSTemporaryDirectory(), pathToDownloadTests]]
                                              error:&error];
    if (error) {
        XCTFail(@"Error while deleting tests directory");
        NSLog(@"Error : %d - %@", error.code, error.localizedDescription);
    }
    
    [super tearDown];
}


#pragma mark - TCBlobDownloadManager


- (void)testSingleton
{
    TCBlobDownloadManager *manager = [TCBlobDownloadManager sharedDownloadManager];
    XCTAssertNotNil(manager, @"TCBlobDownloadManager shared instance is nil.");
}

- (void)testSharedInstanceReturnsSameSingletonObject
{
    TCBlobDownloadManager *m1 = [TCBlobDownloadManager sharedDownloadManager];
    TCBlobDownloadManager *m2 = [TCBlobDownloadManager sharedDownloadManager];
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
                          @"Default download path is not setting correctly");
}

- (void)testAllOperationsCorrectlyCancelled
{
    for (NSInteger i = 0; i < 10; i++) {
        [self.manager startDownloadWithURL:[NSURL URLWithString:kValidURLToDownload]
                                customPath:nil
                                  delegate:nil];
    }
    [self.manager cancelAllDownloadsAndRemoveFiles:YES];
    XCTAssert(self.manager.downloadCount == 0,
                  @"TCBlobDownloadManager cancelAllDownload did not properly finished all operations.");
}


#pragma mark - TCBlobDownload


- (void)testOperationCorrectlyCancelled
{
    TCBlobDownload *download = [self.manager startDownloadWithURL:[NSURL URLWithString:kValidURLToDownload]
                                                       customPath:nil
                                                         delegate:nil];
    [download cancelDownloadAndRemoveFile:YES];
    XCTAssert(self.manager.downloadCount == 0, @"Operation TCBlobDownload did not finish properly.");
}

- (void)testFileIsRemovedOnCancel
{
    
    /*__block TCBlobDownload *download = [self.manager startDownloadWithURL:[NSURL URLWithString:kValidURLToDownload]
                                                       customPath:[NSString pathWithComponents:@[NSTemporaryDirectory(), pathToDownloadTests]]
                                                    firstResponse:NULL
                                                         progress:^(float receivedLength, float totalLength)
    {
        [download cancelDownloadAndRemoveFile:YES];
    }
                                                            error:NULL
                                                         complete:^(BOOL downloadFinished, NSString *pathToFile)
    {
        __autoreleasing NSError *fileError;
        NSArray *content = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:download.pathToDownloadDirectory
                                                                              error:&fileError];
        if (fileError) {
            XCTFail(@"An error occured while listing files in test downloads directory.");
            NSLog(@"Error : %d - %@", fileError.code, fileError.localizedDescription);
        }
        
        if (content.count > 0) {
            XCTFail(@"Files not removed from disk after download cancellation.");
            NSLog(@"%d file(s) located at %@", content.count, download.pathToDownloadDirectory);
        }
    }];*/
}

@end
