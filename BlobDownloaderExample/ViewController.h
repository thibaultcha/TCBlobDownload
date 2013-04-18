//
//  ViewController.h
//  BlobDownloaderExample
//
//  Created by Thibault Charbonnier on 18/04/13.
//  Copyright (c) 2013 thibaultCha. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BlobDownloaderQueue.h"
#import "BlobDownloader.h"

@interface ViewController : UIViewController <BlobDownloaderDelegate>

@property (nonatomic, retain) UITextField *urlField;
@property (nonatomic, retain) UIButton *downloadButton;
@property (nonatomic, retain) UIButton *cancelButton;

- (void)download;
- (void)cancelAll;

@end
