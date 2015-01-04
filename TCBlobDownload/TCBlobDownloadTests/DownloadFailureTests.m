//
//  TCBlobDownloadErrorTests.m
//  TCBlobDownload
//
//  Created by Thibault Charbonnier on 23/10/2013.
//  Copyright (c) 2013 thibaultCha. All rights reserved.
//

#import "TCBlobDownloadTestsBase.h"


#pragma mark - Download Handler Mock


@interface DownloadHandlerFailure : XCTestCase <TCBlobDownloaderDelegate>
@property (nonatomic, strong) XCTestExpectation *expectation;
@property (nonatomic, assign) BOOL didStopWithErrorCalled;
- (instancetype)initWithExpecation:(XCTestExpectation *)expectation;
@end

@implementation DownloadHandlerFailure
- (instancetype)initWithExpecation:(XCTestExpectation *)expectation
{
    self = [super init];
    if (self) {
        self.expectation = expectation;
    }
    return self;
}
- (void)download:(TCBlobDownloader *)blobDownload didStopWithError:(NSError *)error
{
    XCTAssertTrue([NSThread isMainThread], @"didStopWithError: is not called on main thread");
    XCTAssertNotNil(error, @"Error is nil in delegate download:didStopWithError:");
    self.didStopWithErrorCalled = YES;
}
- (void)download:(TCBlobDownloader *)blobDownload didFinishWithSuccess:(BOOL)downloadFinished atPath:(NSString *)pathToFile
{
    XCTAssertFalse(downloadFinished);
    [self.expectation fulfill];
}
@end


#pragma mark - TCBlobDownloadErrorTests


@interface DownloadFailureTests : TCBlobDownloadTestsBase
@end

@implementation DownloadFailureTests

- (void)testErrorInvalidURL
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"should call the error block"];
    
    [self.manager startDownloadWithURL:self.invalidURL
                            customPath:nil
                         firstResponse:NULL
                              progress:NULL
                                 error:^(NSError *error) {
                                     XCTAssert([NSThread isMainThread], @"Error block is not called on main thread");
                                     XCTAssertNotNil(error, @"No error passed for invalid URL");
                                     XCTAssertEqual(error.code, TCBlobDownloadErrorInvalidURL, @"Incoherent error code provided for invalud URL");
                                     [expectation fulfill];
                                 }
                              complete:NULL];
    
    [self waitForExpectationsWithTimeout:kDefaultAsyncTimeout handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Expectation error: %@", error);
        }
    }];
}

- (void)testErrorHTTP
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"should call the error block"];
    
    [self.manager startDownloadWithURL:[self fixtureDownlaodWithStatusCode:404]
                            customPath:nil
                         firstResponse:NULL
                              progress:NULL
                                 error:^(NSError *error) {
                                     XCTAssertNotNil(error.userInfo[TCBlobDownloadErrorHTTPStatusKey], @"error userInfo does not contains TCHTTPStatusCode field.");
                                     XCTAssertEqual([error.userInfo[TCBlobDownloadErrorHTTPStatusKey] integerValue], 404, @"Error code should equal 404 for this URL");
                                     [expectation fulfill];
                                 }
                              complete:NULL];
    
    [self waitForExpectationsWithTimeout:kDefaultAsyncTimeout handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Expectation error: %@", error);
        }
    }];
}

- (void)testDelegateMethodsShouldBeCalled
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"should call the delegate error method"];
    
    DownloadHandlerFailure *handler = [[DownloadHandlerFailure alloc] initWithExpecation:expectation];

    [self.manager startDownloadWithURL:self.invalidURL
                            customPath:nil
                              delegate:handler];

    [self waitForExpectationsWithTimeout:kDefaultAsyncTimeout handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Expectation error: %@", error);
        }
    }];
    
    XCTAssertTrue(handler.didStopWithErrorCalled, @"didStopWithError: not called");
}

@end
