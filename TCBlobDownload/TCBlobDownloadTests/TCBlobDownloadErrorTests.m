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
                                     XCTAssertNotNil(error.userInfo[@"httpStatus"], @"Error.userInfos does not contains httpStatus field.");
                                     XCTAssertEqual([error.userInfo[@"httpStatus"] integerValue], 404, @"Error code should equal 404 for this URL");
                                     [self notify:XCTAsyncTestCaseStatusSucceeded];
                                 }
                              complete:NULL];
    
    [self waitForStatus:XCTAsyncTestCaseStatusSucceeded timeout:5];
}

@end
