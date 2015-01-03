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
    
    _manager = [[TCBlobDownloadManager alloc] init];
    self.validURL = [NSURL URLWithString:kValidURLToDownload];
    self.invalidURL = [NSURL URLWithString:kInvalidURLToDownload];
    self.testsDirectory = [NSString pathWithComponents:@[NSTemporaryDirectory(), kPathToDownloadTests]];
    
    NSError * __autoreleasing error;
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
    
    NSError * __autoreleasing error;
    [[NSFileManager defaultManager] removeItemAtPath:self.testsDirectory
                                               error:&error];
    
    if (error.code != 513) {
        XCTAssertNil(error, @"Error while removing tests directory - %@", error);
    }
    
    [super tearDown];
}

@end
