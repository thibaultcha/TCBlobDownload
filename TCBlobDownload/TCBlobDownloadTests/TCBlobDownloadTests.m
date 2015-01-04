//
//  TCBlobDownloadTests.m
//  TCBlobDownloadTests
//
//  Created by Thibault Charbonnier on 09/07/13.
//  Copyright (c) 2013 thibaultCha. All rights reserved.
//

#import "TCBlobDownloadTestsBase.h"


#pragma mark - Download Handler Mock


@interface DownloadHandlerSuccess : XCTestCase <TCBlobDownloaderDelegate>
@property (nonatomic, weak) XCTestExpectation *expectation;
@property (nonatomic, assign) BOOL didReceiveFirstResponseCalled;
@property (nonatomic, assign) BOOL didReceiveDataCalled;
@end

@implementation DownloadHandlerSuccess
- (instancetype)initWithExpectation:(XCTestExpectation *)expectation
{
    self = [super init];
    if (self) {
        self.expectation = expectation;
    }
    return self;
}
- (void)download:(TCBlobDownloader *)blobDownload didReceiveFirstResponse:(NSURLResponse *)response
{
    XCTAssertTrue([NSThread isMainThread], @"didReceiveFirstResponse: is not called on main thread");
    self.didReceiveFirstResponseCalled = YES;
}
- (void)download:(TCBlobDownloader *)blobDownload didReceiveData:(uint64_t)receivedLength onTotal:(uint64_t)totalLength progress:(float)progress
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        XCTAssertTrue([NSThread isMainThread], @"didReceiveData: is not called on main thread");
        self.didReceiveDataCalled = YES;
    });
}
- (void)download:(TCBlobDownloader *)blobDownload didFinishWithSuccess:(BOOL)downloadFinished atPath:(NSString *)pathToFile
{
    XCTAssertTrue([NSThread isMainThread], @"didFinishWithSuccess: is not called on main thread");
    [self.expectation fulfill];
}
@end


#pragma mark - TCBlobDownloadTests


@interface TCBlobDownloadTests : TCBlobDownloadTestsBase
@end

@implementation TCBlobDownloadTests

- (void)testInvalidDownloadPath
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"should return an error"];
 
    TCBlobDownloader *download = [[TCBlobDownloader alloc] initWithURL:[self fixtureDownloadWithNumberOfBytes:4096]
                                                          downloadPath:nil
                                                         firstResponse:NULL
                                                              progress:NULL
                                                                 error:^(NSError *error) {
                                                                     XCTAssertNotNil(error);
                                                                     [expectation fulfill];
                                                                 }
                                                              complete:NULL];
    [self.manager startDownload:download];
    
    [self waitForExpectationsWithTimeout:kDefaultAsyncTimeout handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Expectation error: %@", error);
        }
    }];
}

- (void)testCreateDownloadPath
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"should create the download path"];
    NSString *testDirectory = [NSString pathWithComponents:@[self.manager.defaultDownloadPath, @"create_me"]];
    
    [self.manager startDownloadWithURL:[self fixtureDownloadWithNumberOfBytes:12]
                            customPath:testDirectory
                         firstResponse:^(NSURLResponse *response) {
                             [expectation fulfill];
                         }
                              progress:NULL
                                 error:NULL
                              complete:NULL];
        
    [self waitForExpectationsWithTimeout:kDefaultAsyncTimeout handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Expectation error: %@", error);
        }
    }];
    
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:testDirectory];
    XCTAssert(exists, @"Custom download directory not created");
}

- (void)DISABLED_testOperationCorrectlyCancelled
{
    TCBlobDownloader *download = [self.manager startDownloadWithURL:[self fixtureDownloadWithNumberOfBytes:4096]
                                                         customPath:nil
                                                           delegate:nil];
    [download cancelDownloadAndRemoveFile:NO];
    
    XCTAssert(self.manager.downloadCount == 0, @"TCBlobDownload operation didn't get removed from NSOperationQueue");
    
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:download.pathToFile];
    XCTAssertTrue(exists, @"File removed after cancellation");
}

- (void)DISABLED_testFileIsRemovedOnCancel
{
    TCBlobDownloader *download = [self.manager startDownloadWithURL:[self fixtureDownloadWithNumberOfBytes:4096]
                                                         customPath:nil
                                                           delegate:nil];
    [download cancelDownloadAndRemoveFile:YES];
    
    [self waitForCondition:download.state == TCBlobDownloadStateCancelled];
    
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:download.pathToFile];
    XCTAssertFalse(exists, @"File not removed after cancellation");
}

- (void)testBlocksShouldBeCalled
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"should call the blocks"];
    __block BOOL firstResponseCalled, progressCalled, completeCalled;
    
    [self.manager startDownloadWithURL:[self fixtureDownloadWithNumberOfBytes:10000000]
                            customPath:nil
                         firstResponse:^(NSURLResponse *response) {
                             XCTAssert([NSThread isMainThread], @"First response block is not called on main thread");
                             firstResponseCalled = YES;
                         }
                         progress:^(uint64_t receivedLength, uint64_t totalLength, NSInteger remainingTime, float progress) {
                             XCTAssert([NSThread isMainThread], @"Progress block is not called on main thread");
                             progressCalled = YES;
                         }
                         error:NULL
                         complete:^(BOOL downloadFinished, NSString *pathToFile) {
                             XCTAssert([NSThread isMainThread], @"Completion block is not called on main thread");
                             completeCalled = YES;
                             [expectation fulfill];
                         }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Expectation error: %@", error);
        }
    }];
    
    XCTAssertTrue(firstResponseCalled);
    XCTAssertTrue(progressCalled);
    XCTAssertTrue(completeCalled);
}

- (void)testDelegateMethodsShouldBeCalled
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"should call the delegate methods"];
    DownloadHandlerSuccess *handler = [[DownloadHandlerSuccess alloc] initWithExpectation:expectation];
    
    [self.manager startDownloadWithURL:self.validURL
                            customPath:nil
                              delegate:handler];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Expectation error: %@", error);
        }
    }];
    
    XCTAssertTrue(handler.didReceiveFirstResponseCalled);
    XCTAssertTrue(handler.didReceiveDataCalled);
}

@end
