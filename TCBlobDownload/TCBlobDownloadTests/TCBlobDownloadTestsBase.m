//
//  TCBlobDownloadTestsBase.m
//  TCBlobDownload
//
//  Created by Thibault Charbonnier on 02/03/2014.
//  Copyright (c) 2014 thibaultCha. All rights reserved.
//

#import "TCBlobDownloadTestsBase.h"

@implementation TCBlobDownloadTestsBase

- (void)setUp
{
    [super setUp];
    
    self.manager = [[TCBlobDownloadManager alloc] init];
    self.httpbinURL = [NSURL URLWithString:kHttpbinURL];
    self.validURL = [NSURL URLWithString:kValidURLToDownload];
    self.invalidURL = [NSURL URLWithString:kInvalidURLToDownload];
    self.testsDirectory = [NSString pathWithComponents:@[NSTemporaryDirectory(), kTestsDirectory]];
    
    NSError *error;
    [[NSFileManager defaultManager] createDirectoryAtPath:self.testsDirectory
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:&error];
    
    XCTAssertNil(error, @"Error while creating tests directory - %@", error);
    
    [self.manager setDefaultDownloadPath:self.testsDirectory];
}

- (void)tearDown
{
    [[NSFileManager defaultManager] removeItemAtPath:self.testsDirectory
                                               error:nil];
    [super tearDown];
}

- (NSURL *)fixtureDownloadWithNumberOfBytes:(NSInteger)bytes
{
    return [NSURL URLWithString:[NSString stringWithFormat:@"stream-bytes/%ld", (long) bytes] relativeToURL:self.httpbinURL];
}

- (NSURL *)fixtureDownlaodWithStatusCode:(NSInteger)status
{
    return [NSURL URLWithString:[NSString stringWithFormat:@"%ld", (long) status] relativeToURL:self.httpbinURL];
}

- (void)waitForCondition:(BOOL)condition
{
    NSDate *date = [NSDate date];
    BOOL timedOut;
    while (!condition && !timedOut) {
        timedOut = [date timeIntervalSinceNow] < -5;
    }
    
    if (timedOut) {
        XCTFail(@"Timed out");
    }
}

@end
