//
//  ViewController.m
//  TCBlobDownloadExample
//
//  Created by Thibault Charbonnier on 18/04/13.
//  Copyright (c) 2013 thibaultCha. All rights reserved.
//

#import "ViewController.h"
#import "MultipleViewController.h"

@implementation ViewController


#pragma mark - Init


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.sharedDownloadManager = [TCBlobDownloadManager sharedInstance];
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
    /*
    [self.sharedDownloadManager startDownloadWithURL:[NSURL URLWithString:self.urlField.text]
                                          customPath:nil
                                            delegate:self];
    */
    
    // Blocks
    [self.sharedDownloadManager startDownloadWithURL:[NSURL URLWithString:self.urlField.text]
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
                                            }];
    [self.urlField resignFirstResponder];
}

- (void)cancelAll:(id)sender
{
    [self.sharedDownloadManager cancelAllDownloadsAndRemoveFiles:YES];
}

- (IBAction)switchToMultipleDownloads:(id)sender
{
    MultipleViewController *multipleViewController = [MultipleViewController new];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:multipleViewController];
    
    [self presentViewController:navController animated:YES completion:nil];
}

#pragma mark - TCBlobDownloaderDelegate


- (void)download:(TCBlobDownloader *)blobDownload didReceiveFirstResponse:(NSURLResponse *)response
{

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

}

@end
