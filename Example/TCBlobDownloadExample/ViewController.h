//
//  ViewController.h
//  TCBlobDownloadExample
//
//  Created by Thibault Charbonnier on 18/04/13.
//  Copyright (c) 2013 thibaultCha. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TCBlobDownload/TCBlobDownload.h>

@interface ViewController : UIViewController <TCBlobDownloaderDelegate>

@property (nonatomic , strong) TCBlobDownloadManager *sharedDownloadManager;
@property (weak, nonatomic) IBOutlet UITextField *urlField;
@property (weak, nonatomic) IBOutlet UIButton *downloadButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UILabel *remainingTime;

- (IBAction)download:(id)sender;
- (IBAction)cancelAll:(id)sender;
- (IBAction)switchToMultipleDownloads:(id)sender;

@end
