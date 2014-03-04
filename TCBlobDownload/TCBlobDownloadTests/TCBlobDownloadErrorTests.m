//
//  TCBlobDownloadErrorTests.m
//  TCBlobDownload
//
//  Created by Thibault Charbonnier on 23/10/2013.
//  Copyright (c) 2013 thibaultCha. All rights reserved.
//

#import "TCBlobDownloadTestsBase.h"

@interface TCBlobDownloadErrorTests : TCBlobDownloadTestsBase
@end

@implementation TCBlobDownloadErrorTests

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
                                     XCTAssertNotNil(error.userInfo[TCHTTPStatusCode], @"error.userInfos does not contains TCHTTPStatusCode field.");
                                     XCTAssertEqual([error.userInfo[TCHTTPStatusCode] integerValue], (NSInteger)404, @"Error code should equal 404 for this URL");
                                     [self notify:XCTAsyncTestCaseStatusSucceeded];
                                 }
                              complete:NULL];
    
    [self waitForStatus:XCTAsyncTestCaseStatusSucceeded timeout:5];
}

@end
