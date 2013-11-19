//
//  TCBlobDownloadTests.m
//  TCBlobDownloadTests
//
//  Created by Thibault Charbonnier on 09/07/13.
//  Copyright (c) 2013 thibaultCha. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "XCTestCase+AsyncTesting.h"

#import "TestValues.h"
#import "TCBlobDownloadManager.h"

@interface TCBlobDownloadTests : XCTestCase
@property (nonatomic, strong) TCBlobDownloadManager *manager;
@property (nonatomic, copy) NSURL *validURL;
@property (nonatomic, copy) NSString *testsDirectory;
@end

@implementation TCBlobDownloadTests

- (void)setUp
{
    [super setUp];
    
    _manager = [[TCBlobDownloadManager alloc] init];
    self.validURL = [NSURL URLWithString:kValidURLToDownload];
    self.testsDirectory = [NSString pathWithComponents:@[NSHomeDirectory(), pathToDownloadTests]];
    
    __autoreleasing NSError *error;
    [[NSFileManager defaultManager] createDirectoryAtPath:self.testsDirectory
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:&error];

    XCTAssertNil(error, @"Error while creating tests directory - %@", error);
    
    [self.manager setDefaultDownloadPath:self.testsDirectory];
}

- (void)tearDown
{
    self.manager = nil;
    self.validURL = nil;
    

    __autoreleasing NSError *error;
    [[NSFileManager defaultManager] removeItemAtPath:self.testsDirectory
                                                   error:&error];

    XCTAssertNil(error, @"Error while removing tests directory - %@", error);
    
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
                          @"Default download path is not set correctly");
}

- (void)testCreatePathFromPath
{
    // test if null
    // test if exists
}

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


#pragma mark - TCBlobDownload


- (void)testShouldHandleNilDownloadPath
{
    TCBlobDownload *download1 = [[TCBlobDownload alloc] initWithURL:self.validURL
                                                       downloadPath:nil
                                                           delegate:nil];
    [self.manager startDownload:download1];
    XCTAssertEqualObjects(self.manager.defaultDownloadPath, download1.pathToDownloadDirectory,
                          @"TCBlobDownloadManager did not set defaultPath in startDownload:");
    
    TCBlobDownload *download2 = [self.manager startDownloadWithURL:self.validURL
                                                        customPath:nil
                                                          delegate:nil];
    XCTAssertEqualObjects(self.manager.defaultDownloadPath, download2.pathToDownloadDirectory,
                          @"TCBlobDownloadManager did not set defaultPath in startDownloadWithURL:customPath:delegate:");
    
    TCBlobDownload *download3 = [self.manager startDownloadWithURL:self.validURL
                                                        customPath:nil
                                                     firstResponse:NULL
                                                          progress:NULL
                                                             error:NULL
                                                          complete:NULL];
    XCTAssertEqualObjects(self.manager.defaultDownloadPath, download3.pathToDownloadDirectory,
                          @"TCBlobDownloadManager did not set defaultPath in startDownloadWithURL:customPath:firstResponse:progress:error:complete:");
    
}

- (void)testCreateDownloadDirectory
{
    NSString *testDirectory = [NSString pathWithComponents:@[self.manager.defaultDownloadPath, @"create_me"]];
    
    [self.manager startDownloadWithURL:self.validURL
                            customPath:testDirectory
                         firstResponse:^(NSURLResponse *response) {
                             
                         }
                              progress:^(float receivedLength, float totalLength) {
                                  BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:testDirectory];
                                  XCTAssert(exists, @"Custom download directory not created");
                             
                                  [self notify:XCTAsyncTestCaseStatusSucceeded];
                              }
                                 error:NULL
                              complete:NULL];
    
    [self waitForStatus:XCTAsyncTestCaseStatusSucceeded timeout:5];
    
    [self.manager startDownloadWithURL:self.validURL
                            customPath:testDirectory
                              delegate:nil];
    
    [self waitForTimeout:kDefaultAsyncTimeout];
    
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:testDirectory];
    XCTAssert(exists, @"Custom download directory not created");
}

- (void)testOperationCorrectlyCancelled
{
    TCBlobDownload *download = [self.manager startDownloadWithURL:self.validURL
                                                       customPath:nil
                                                         delegate:nil];
    [self waitForTimeout:kDefaultAsyncTimeout];
    
    [download cancelDownloadAndRemoveFile:YES];
    XCTAssert(self.manager.downloadCount == 0, @"Operation TCBlobDownload did not finish properly.");
}

- (void)testFileIsRemovedOnCancel
{
    TCBlobDownload *download = [self.manager startDownloadWithURL:self.validURL
                                                       customPath:nil
                                                         delegate:nil];
    
    [self waitForTimeout:kDefaultAsyncTimeout];
    
    [download cancelDownloadAndRemoveFile:YES];
    
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
}

@end
