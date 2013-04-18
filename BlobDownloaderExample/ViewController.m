//
//  ViewController.m
//  BlobDownloaderExample
//
//  Created by Thibault Charbonnier on 18/04/13.
//  Copyright (c) 2013 thibaultCha. All rights reserved.
//

#define BUTTON_WIDTH 100
#define FIELD_PADDING 10

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// URI label
    _urlField = [[UITextField alloc] initWithFrame:CGRectMake(FIELD_PADDING,
                                                              self.view.bounds.size.height / 2 - 2*BUTTON_WIDTH,
                                                              self.view.bounds.size.width - FIELD_PADDING,
                                                              50)];
    self.urlField.placeholder = @"http://give.me/a/big/file.avi";
    self.urlField.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.urlField];
    // Dowload button
    self.downloadButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.downloadButton setFrame:CGRectMake(self.view.bounds.size.width / 2 - (BUTTON_WIDTH / 2),
                                        self.view.bounds.size.height / 2 - BUTTON_WIDTH,
                                        BUTTON_WIDTH,
                                        30)];
    [self.downloadButton setTitle:@"Download" forState:UIControlStateNormal];
    [self.downloadButton addTarget:self
                       action:@selector(download)
             forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.downloadButton];
    // Cancel button
    self.downloadButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.downloadButton setFrame:CGRectMake(self.view.bounds.size.width / 2 - (BUTTON_WIDTH / 2),
                                             self.view.bounds.size.height / 2 - (BUTTON_WIDTH / 2),
                                             BUTTON_WIDTH,
                                             30)];
    [self.downloadButton setTitle:@"Cancel all" forState:UIControlStateNormal];
    [self.downloadButton addTarget:self
                            action:@selector(cancelAll)
                  forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.downloadButton];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [self setUrlField:nil];
    [self setDownloadButton:nil];
    [self setCancelButton:nil];
}


#pragma mark- Demo


- (void)download
{
    NSString *url = self.urlField.text;
    if ([NSURL URLWithString:url]) {
        BlobDownloaderQueue *sharedQueue = [BlobDownloaderQueue sharedDownloadQueue];
        BlobDownloader *downloader = [[BlobDownloader alloc] initWithUrlString:url
                                                                   andDelegate:self];
        [sharedQueue.operationQueue addOperation:downloader];
    } else {
        NSLog(@"Invalid URL provided.");
    }
}

- (void)cancelAll
{
    BlobDownloaderQueue *sharedQueue = [BlobDownloaderQueue sharedDownloadQueue];
    [sharedQueue.operationQueue cancelAllOperations];
}

@end
