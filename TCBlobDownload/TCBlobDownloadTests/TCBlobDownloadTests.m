//
//  TCBlobDownloadTests.m
//  TCBlobDownloadTests
//
//  Created by Thibault Charbonnier on 09/07/13.
//  Copyright (c) 2013 thibaultCha. All rights reserved.
//

#import "TCBlobDownloadTestsBase.h"

@interface TCBlobDownloadTests : TCBlobDownloadTestsBase <TCBlobDownloaderDelegate>
@property (nonatomic, assign) BOOL delegateCalledOnMainThread;
@end

@implementation TCBlobDownloadTests

- (void)testShouldHandleNilDownloadPath
{
    TCBlobDownloader *download1 = [[TCBlobDownloader alloc] initWithURL:self.validURL
                                                           downloadPath:nil
                                                               delegate:nil];
    [self.manager startDownload:download1];
    XCTAssertEqualObjects(self.manager.defaultDownloadPath, download1.pathToDownloadDirectory,
                          @"TCBlobDownloadManager did not set defaultPath in startDownload:");
    
    TCBlobDownloader *download2 = [self.manager startDownloadWithURL:self.validURL
                                                          customPath:nil
                                                            delegate:nil];
    XCTAssertEqualObjects(self.manager.defaultDownloadPath, download2.pathToDownloadDirectory,
                          @"TCBlobDownloadManager did not set defaultPath in startDownloadWithURL:customPath:delegate:");
    
    TCBlobDownloader *download3 = [self.manager startDownloadWithURL:self.validURL
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
    
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:testDirectory];
    XCTAssert(exists, @"Custom download directory not created");
}

- (void)testOperationCorrectlyCancelled
{
    TCBlobDownloader *download = [self.manager startDownloadWithURL:self.validURL
                                                         customPath:nil
                                                           delegate:nil];
    [self waitForTimeout:kDefaultAsyncTimeout];
    
    [download cancelDownloadAndRemoveFile:YES];
    XCTAssert(self.manager.downloadCount == 0, @"Operation TCBlobDownload did not finish properly.");
}

- (void)testFileIsRemovedOnCancel
{
    TCBlobDownloader *download = [self.manager startDownloadWithURL:self.validURL
                                                         customPath:nil
                                                           delegate:nil];
    
    [self waitForTimeout:kDefaultAsyncTimeout];
    
    [download cancelDownloadAndRemoveFile:YES];
    
    __autoreleasing NSError *fileError;
    NSArray *content = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:download.pathToDownloadDirectory
                                                                          error:&fileError];
    if (fileError) {
        XCTFail(@"An error occured while listing files in test downloads directory.");
        NSLog(@"Error : %ld - %@", (long) fileError.code, fileError.localizedDescription);
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
    
    [self waitForStatus:XCTAsyncTestCaseStatusSucceeded timeout:5];
}

/*
- (void)testDelegateMethodsShouldBeCalledOnMainThreadOne
{
    [self.manager startDownloadWithURL:self.validURL
                            customPath:nil
                              delegate:self];

    [self waitForStatus:kDidReceiveFirstResponseMethodCalled timeout:kDefaultAsyncTimeout];
    XCTAssert(self.delegateCalledOnMainThread, @"download:didReceiveFirstResponse: is not called on main thread");
    
    [self waitForStatus:kDidReceiveDataMethodCalled timeout:kDefaultAsyncTimeout];
    XCTAssert(self.delegateCalledOnMainThread, @"download:didReceiveData: is not called on main thread");
}
*/
    
/*
- (void)testDelegateMethodsShouldBeCalledOnMainThreadTwo
{
    [self.manager startDownloadWithURL:[NSURL URLWithString:kInvalidURLToDownload]
                            customPath:nil
                              delegate:self];
    
    [self waitForStatus:kDidStopWithErrorMethodCalled timeout:5];
    XCTAssert(self.delegateCalledOnMainThread, @"download:didStopWithError: is not called on main thread");
    
    //[self waitForStatus:kDidFinishWithSuccessMethodCalled timeout:5];
    //XCTAssert(self.delegateCalledOnMainThread, @"download:didFinishWithSuccess: is not called on main thread after error occurring");
}
*/


#pragma mark - TCBlobDownloadDelegate


- (void)download:(TCBlobDownloader *)blobDownload didReceiveFirstResponse:(NSURLResponse *)response
{
    self.delegateCalledOnMainThread = YES;
    [self notify:kDidReceiveFirstResponseMethodCalled];
}

- (void)download:(TCBlobDownloader *)blobDownload didReceiveData:(uint64_t)receivedLength onTotal:(uint64_t)totalLength
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        self.delegateCalledOnMainThread = YES;
        [self notify:kDidReceiveDataMethodCalled];
    });
}

- (void)download:(TCBlobDownloader *)blobDownload didFinishWithSucces:(BOOL)downloadFinished atPath:(NSString *)pathToFile
{
    self.delegateCalledOnMainThread = YES;
    [self notify:kDidFinishWithSuccessMethodCalled];
}

- (void)download:(TCBlobDownloader *)blobDownload didStopWithError:(NSError *)error
{
    self.delegateCalledOnMainThread = YES;
    [self notify:kDidStopWithErrorMethodCalled];
}

@end
