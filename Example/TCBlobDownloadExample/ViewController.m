//
//  ViewController.m
//  TCBlobDownloadExample
//
//  Created by Thibault Charbonnier on 18/04/13.
//  Copyright (c) 2013 thibaultCha. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController


#pragma mark - Init


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.sharedDownloadManager = [TCBlobDownloadManager sharedInstance];
        [self.sharedDownloadManager setMaxConcurrentDownloads:3];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}


#pragma mark - Demo


- (void)download:(id)sender
{
    // Delegate
    for (NSInteger i = 0; i < 50; i++) {
        [self.sharedDownloadManager startDownloadWithURL:[NSURL URLWithString:@"https://github.com/thibaultCha/TCBlobDownload/archive/master.zip"]
                                              customPath:[NSString pathWithComponents:@[NSTemporaryDirectory(), [NSString stringWithFormat:@"%ld", (long)i]]]
                                                delegate:self];
    }
    
    [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(log)
                                   userInfo:nil
                                    repeats:YES];
    //[[NSRunLoop currentRunLoop] addTimer:countTimer forMode:NSRunLoopCommonModes];
    
    // Blocks
    /*[self.sharedDownloadManager startDownloadWithURL:[NSURL URLWithString:self.urlField.text]
                                          customPath:[NSString pathWithComponents:@[NSTemporaryDirectory(), @"example"]]
                                       firstResponse:NULL
                                            progress:^(float receivedLength, float totalLength, NSInteger remainingTime) {
                                                if (remainingTime != -1) {
                                                    [self.remainingTime setText:[NSString stringWithFormat:@"%lds", (long)remainingTime]];
                                                }
                                            }
                                               error:^(NSError *error) {
                                                   NSLog(@"%@", error);
                                               }
                                            complete:^(BOOL downloadFinished, NSString *pathToFile) {
                                                NSString *str = downloadFinished ? @"Completed" : @"Cancelled";
                                                [self.remainingTime setText:str];
                                            }];*/
    [self.urlField resignFirstResponder];
}

- (void)log
{
    NSLog(@"%d", self.sharedDownloadManager.downloadCount);
}

- (void)cancelAll:(id)sender
{
    [self.sharedDownloadManager cancelAllDownloadsAndRemoveFiles:YES];
}


#pragma mark - TCBlobDownloaderDelegate


- (void)download:(TCBlobDownloader *)blobDownload didReceiveFirstResponse:(NSURLResponse *)response
{
    //NSLog(@"%@ downlaod started", blobDownload.pathToDownloadDirectory);
}

- (void)download:(TCBlobDownloader *)blobDownload
  didReceiveData:(uint64_t)receivedLength
         onTotal:(uint64_t)totalLength
{

}

- (void)download:(TCBlobDownloader *)blobDownload didStopWithError:(NSError *)error
{

}

- (void)download:(TCBlobDownloader *)blobDownload didCancelRemovingFile:(BOOL)fileRemoved
{
    
}

- (void)download:(TCBlobDownloader *)blobDownload didFinishWithSucces:(BOOL)downloadFinished atPath:(NSString *)pathToFile
{
    NSLog(@"%@ downlaod finished", [blobDownload.pathToDownloadDirectory lastPathComponent]);
}

@end
