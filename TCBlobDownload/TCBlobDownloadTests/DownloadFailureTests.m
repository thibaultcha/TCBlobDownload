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
@property (nonatomic, weak) TCBlobDownloadTestsBase *tests;
- (instancetype)initWithTests:(TCBlobDownloadTestsBase *)tests;
@end

@implementation DownloadHandlerFailure
- (instancetype)initWithTests:(TCBlobDownloadTestsBase *)tests
{
    self = [super init];
    if (self) {
        self.tests = tests;
    }
    return self;
}
- (void)download:(TCBlobDownloader *)blobDownload didStopWithError:(NSError *)error
{
    XCTAssertTrue([NSThread isMainThread], @"didStopWithError: is not called on main thread");
    XCTAssertNotNil(error, @"Error is nil in delegate download:didStopWithError:");
    [self.tests notify: kDidStopWithErrorMethodCalled];
}
- (void)download:(TCBlobDownloader *)blobDownload didFinishWithSuccess:(BOOL)downloadFinished atPath:(NSString *)pathToFile
{
    XCTAssertFalse(downloadFinished);
    [self.tests notify: kDidFinishWithSuccessMethodCalled];
}
@end


#pragma mark - TCBlobDownloadErrorTests


@interface DownloadFailureTests : TCBlobDownloadTestsBase
@end

@implementation DownloadFailureTests

- (void)testInvalidURL
{
    [self.manager startDownloadWithURL:[NSURL URLWithString:kInvalidURLToDownload]
                            customPath:nil
                         firstResponse:NULL
                              progress:NULL
                                 error:^(NSError *error) {
                                     XCTAssert([NSThread isMainThread], @"Error block is not called on main thread");
                                     XCTAssertNotNil(error, @"No error passed for invalid URL");
                                     XCTAssertEqual((NSUInteger)error.code, TCErrorInvalidURL, @"Incoherent error code provided for invalud URL");
                                     [self notify:XCTAsyncTestCaseStatusSucceeded];
                                 }
                              complete:NULL];
    
    [self waitForStatus:XCTAsyncTestCaseStatusSucceeded timeout:5];
}

- (void)testHTTPErrorStatusCode
{
    [self.manager startDownloadWithURL:[NSURL URLWithString:k404URLToDownload]
                            customPath:nil
                         firstResponse:NULL
                              progress:NULL
                                 error:^(NSError *error) {
                                     XCTAssertNotNil(error.userInfo[TCHTTPStatusCode], @"error userInfo does not contains TCHTTPStatusCode field.");
                                     XCTAssertEqual([error.userInfo[TCHTTPStatusCode] integerValue], (NSInteger)404, @"Error code should equal 404 for this URL");
                                     [self notify:XCTAsyncTestCaseStatusSucceeded];
                                 }
                              complete:NULL];
    
    [self waitForStatus:XCTAsyncTestCaseStatusSucceeded timeout:5];
}

- (void)testDelegateMethodsShouldBeCalled
{
    DownloadHandlerFailure *handler = [[DownloadHandlerFailure alloc] initWithTests:self];

    [self.manager startDownloadWithURL:[NSURL URLWithString:kInvalidURLToDownload]
                            customPath:nil
                              delegate:handler];
    
    [self waitForStatus:kDidStopWithErrorMethodCalled timeout:kDefaultAsyncTimeout];
    [self waitForStatus:kDidFinishWithSuccessMethodCalled timeout:kDefaultAsyncTimeout];
}

@end
