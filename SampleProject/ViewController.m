//
//  ViewController.m
//  BlobDownloaderExample
//
//  Created by Thibault Charbonnier on 18/04/13.
//  Copyright (c) 2013 thibaultCha. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController


#pragma mark - Init


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.sharedDownloadManager = [TCBlobDownloadManager sharedDownloadManager];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [self setUrlField:nil];
    [self setDownloadButton:nil];
    [self setCancelButton:nil];
}


#pragma mark - Demo


- (void)download:(id)sender
{
    // Delegate
    /*[self.sharedDownloadManager startDownloadWithURL:self.urlField.text
                                            customPath:nil
                                           andDelegate:self];*/
    
    // BLOCK POWA
    [self.sharedDownloadManager startDownloadWithURL:self.urlField.text
                                          customPath:nil
                                  firstResponseBlock:^(NSURLResponse *response) {
                                      
                                      NSLog(@"first response");
                                      
                                  } 
                                  progressBlock:^(float receivedLength, float totalLength) {
                                           
                                      //NSLog(@"Incoming!");
                                           
                                  }
                                  errorBlock:^(NSError *error) {
                                              
                                      NSLog(@"Shit happens.");
                                              
                                  }
                                  downloadFinishedBlock:^(NSString *pathToFile){
                                         
                                      NSLog(@"Done.");
                                         
                                  }];
    
    [self.urlField resignFirstResponder];
}

- (void)cancelAll:(id)sender
{
    [self.sharedDownloadManager cancelAllDownloadsAndRemoveFiles:YES];
}


#pragma mark - BlobDownloadManager Delegate (Optional, your choice)

- (void)download:(TCBlobDownload *)blobDownload didReceiveFirstResponse:(NSURLResponse *)response
{
    
}

- (void)download:(TCBlobDownload *)blobDownload
  didReceiveData:(uint64_t)receivedLength
         onTotal:(uint64_t)totalLength
{

}

- (void)download:(TCBlobDownload *)blobDownload didStopWithError:(NSError *)error
{

}


- (void)downloadDidFinishWithDownload:(TCBlobDownload *)blobDownload
{
    
}

@end
