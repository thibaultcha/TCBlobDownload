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
    self.manager = nil;
    self.validURL = nil;
    self.invalidURL = nil;
    self.testsDirectory = nil;
    
    NSError *error;
    [[NSFileManager defaultManager] removeItemAtPath:self.testsDirectory
                                               error:&error];
    
    //if (error.code != 513) {
        XCTAssertNil(error, @"Error while removing tests directory - %@", error);
    //}
    
    [super tearDown];
}

- (NSURL *)fixtureDownloadWithNumberOfBytes:(NSInteger)bytes
{
    return [NSURL URLWithString:[NSString stringWithFormat:@"stream-bytes/%ld", (long) bytes] relativeToURL:self.httpbinURL];
}

@end
