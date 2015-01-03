//
//  TCBlobDownloadTests.m
//  TCBlobDownloadTests
//
//  Created by Thibault Charbonnier on 09/07/13.
//  Copyright (c) 2013 thibaultCha. All rights reserved.
//

#import "TCBlobDownloadTestsBase.h"

/*
#pragma mark - Download Handler Mock


@interface DownloadHandlerSuccess : XCTestCase <TCBlobDownloaderDelegate>
@property (nonatomic, weak) TCBlobDownloadTestsBase *tests;
@property (nonatomic, assign) BOOL didReceiveFirstResponseCalled;
@property (nonatomic, assign) BOOL didReceiveDataCalled;
- (instancetype)initWithTests:(TCBlobDownloadTestsBase *)tests;
@end

@implementation DownloadHandlerSuccess
- (instancetype)initWithTests:(TCBlobDownloadTestsBase *)tests
{
    self = [super init];
    if (self) {
        self.tests = tests;
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
    [self.tests notify: kDidFinishWithSuccessMethodCalled];
}
@end


#pragma mark - TCBlobDownloadTests


@interface TCBlobDownloadTests : TCBlobDownloadTestsBase
@end

@implementation TCBlobDownloadTests

- (void)testInvalidDownloadPath
{
    //XCTestExpectation *expectation = [self expectationWithDescription:@"should cancel all downloads"];
 
    TCBlobDownloader *download = [[TCBlobDownloader alloc] initWithURL:self.validURL
                                                          downloadPath:nil
                                                         firstResponse:NULL
                                                              progress:NULL
                                                                 error:^(NSError *error) {
                                                                     XCTAssertNotNil(error);
                                                                     [self notify:XCTAsyncTestCaseStatusSucceeded];
                                                                 }
                                                              complete:NULL];
    [self.manager startDownload:download];
    
    [self waitForStatus:XCTAsyncTestCaseStatusSucceeded timeout:kDefaultAsyncTimeout];
}

- (void)testCreateDownloadPath
{
    NSString *testDirectory = [NSString pathWithComponents:@[self.manager.defaultDownloadPath, @"create_me"]];
    
    [self.manager startDownloadWithURL:self.validURL
                            customPath:testDirectory
                         firstResponse:NULL
                              progress:^(uint64_t receivedLength, uint64_t totalLength, NSInteger remainingTime, float progress) {
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
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:testDirectory], @"Custom download directory not created");
}

- (void)testOperationCorrectlyCancelled
{
    TCBlobDownloader *download = [self.manager startDownloadWithURL:self.validURL
                                                         customPath:nil
                                                           delegate:nil];
    [self waitForTimeout:kDefaultAsyncTimeout];
    
    [download cancelDownloadAndRemoveFile:YES];
    XCTAssert(self.manager.downloadCount == 0, @"TCBlobDownload operation didn't get removed from NSOperationQueue");
}

- (void)testFileIsRemovedOnCancel
{
    TCBlobDownloader *download = [self.manager startDownloadWithURL:self.validURL
                                                         customPath:nil
                                                           delegate:nil];
    [self waitForTimeout:kDefaultAsyncTimeout];
    
    [download cancelDownloadAndRemoveFile:YES];
    
    __autoreleasing NSError *fileError;
    NSArray *content = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:download.pathToDownloadDirectory
                                                                           error:&fileError];
    if (fileError) {
        XCTFail(@"An error occured while listing files in test downloads directory.");
        NSLog(@"Error: %@", fileError);
    }
    if (content.count > 0) {
        XCTFail(@"Files not removed from disk after download cancellation.");
        NSLog(@"%ld file(s) located at %@", (unsigned long)content.count, download.pathToDownloadDirectory);
    }
}

- (void)testCallbacksBlocksShouldBeCalledOnMainThread
{
    [self.manager startDownloadWithURL:self.validURL
                            customPath:nil
                         firstResponse:^(NSURLResponse *response) {
                             XCTAssert([NSThread isMainThread], @"First response block is not called on main thread");
                         }
                         progress:^(uint64_t receivedLength, uint64_t totalLength, NSInteger remainingTime, float progress) {
                             XCTAssert([NSThread isMainThread], @"Progress block is not called on main thread");
                         }
                         error:NULL
                         complete:^(BOOL downloadFinished, NSString *pathToFile) {
                             XCTAssert([NSThread isMainThread], @"Completion block is not called on main thread");
                             [self notify:XCTAsyncTestCaseStatusSucceeded];
                         }];
    
    [self waitForStatus:XCTAsyncTestCaseStatusSucceeded timeout:10.0];
}

- (void)testDelegateMethodsShouldBeCalled
{
    DownloadHandlerSuccess *handler = [[DownloadHandlerSuccess alloc] initWithTests:self];
    
    [self.manager startDownloadWithURL:self.validURL
                            customPath:nil
                              delegate:handler];
    
    [self waitForStatus:kDidFinishWithSuccessMethodCalled timeout:5.0];
    XCTAssertTrue(handler.didReceiveFirstResponseCalled);
    XCTAssertTrue(handler.didReceiveDataCalled);
}

@end
*/