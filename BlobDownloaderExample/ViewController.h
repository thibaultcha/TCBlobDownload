//
//  ViewController.h
//  BlobDownloaderExample
//
//  Created by Thibault Charbonnier on 18/04/13.
//  Copyright (c) 2013 thibaultCha. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BlobDownloadManager.h"

@interface ViewController : UIViewController <BlobDownloadManagerDelegate>

@property (assign, nonatomic) BlobDownloadManager *sharedDownloadManager;
@property (weak, nonatomic) IBOutlet UITextField *urlField;
@property (weak, nonatomic) IBOutlet UIButton *downloadButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

- (IBAction)download:(id)sender;
- (IBAction)cancelAll:(id)sender;

@end
