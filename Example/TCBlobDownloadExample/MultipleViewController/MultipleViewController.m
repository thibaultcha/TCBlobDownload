//
//  MultipleViewController.m
//  TCBlobDownloadExample
//
//  Created by Albert on 27.04.14.
//  Copyright (c) 2014 thibaultCha. All rights reserved.
//

#import "MultipleViewController.h"

#define kDownloadPath [NSString pathWithComponents:@[NSTemporaryDirectory(), @"multipleExample"]]

static NSString * const kDownloadCellIdentifier = @"downloadCell";
static NSString * const kURLKey = @"URL";
static NSString * const kNameKey = @"name";

@interface MultipleViewController ()
@property (nonatomic, strong) NSMutableArray *currentDownloads;
- (void)dismiss:(id)sender;
- (void)showAddDownloadAlert:(id)sender;
- (NSArray *)defaultDownloads;
- (NSString *)subtitleForDownload:(TCBlobDownloader *)download;
@end

@implementation MultipleViewController


#pragma mark - View Lifecycle


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _currentDownloads = [NSMutableArray new];

    [self setTitle:@"Multiple Downloads"];

    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                                             target:self
                                                                                             action:@selector(dismiss:)]];
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                            target:self
                                                                                            action:@selector(showAddDownloadAlert:)]];
}


#pragma mark - Internal Methods


- (void)dismiss:(id)sender
{
    [[TCBlobDownloadManager sharedInstance] cancelAllDownloadsAndRemoveFiles:YES];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showAddDownloadAlert:(id)sender
{
    UIAlertView *addAlertView = [[UIAlertView alloc] initWithTitle:@"Add Download"
                                                           message:nil
                                                          delegate:self
                                                 cancelButtonTitle:@"Cancel"
                                                 otherButtonTitles:@"Add this URL", @"~ Multiple Test Downloads ~", nil];
    [addAlertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
    
    UITextField *textField = [addAlertView textFieldAtIndex:0];
    [textField setPlaceholder:@"http://"];
    
    [addAlertView show];
}

- (NSArray *)defaultDownloads
{
    static NSMutableArray *_downloads = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _downloads = [NSMutableArray new];
        [_downloads addObject:@{ kURLKey : @"https://github.com/thibaultCha/TCBlobDownload/archive/master.zip",
                                 kNameKey: @"TCBlobDownload master branch" }];
        
        [_downloads addObject:@{ kURLKey : @"https://github.com/thibaultCha/Equiprose/archive/master.zip",
                                 kNameKey: @"Equiprose master branch" }];
        
        [_downloads addObject:@{ kURLKey : @"https://api.soundcloud.com/tracks/130355303/stream?client_id=b45b1aa10f1ac2941910a7f0d10f8e28",
                                 kNameKey: @"Soundcloud 1" }];
        
        [_downloads addObject:@{ kURLKey : @"https://api.soundcloud.com/tracks/126240832/download?client_id=b45b1aa10f1ac2941910a7f0d10f8e28",
                                 kNameKey: @"Soundcloud 2" }];
    });
    
    return _downloads;
}

- (NSString *)subtitleForDownload:(TCBlobDownloader *)download
{
    NSString *stateString;
    
    switch (download.state) {
        case TCBlobDownloadStateReady:
            stateString = @"Ready";
            break;
        case TCBlobDownloadStateDownloading:
            stateString = @"Downloading";
            break;
        case TCBlobDownloadStateDone:
            stateString = @"Done";
            break;
        case TCBlobDownloadStateCancelled:
            stateString = @"Cancelled";
            break;
        case TCBlobDownloadStateFailed:
            stateString = @"Failed";
            break;
        default:
            break;
    }
    
    return [NSString stringWithFormat:@"%i%% • %lis left • State: %@",
            (int)(download.progress * 100),
            (long)download.remainingTime,
            stateString];
}


#pragma mark - UIAlertView Delegate


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex) {
        if (buttonIndex == 1) {
            NSString *urlString = [alertView textFieldAtIndex:0].text;
            
            TCBlobDownloader *download = [[TCBlobDownloader alloc] initWithURL:[NSURL URLWithString:urlString]
                                                                  downloadPath:kDownloadPath
                                                                      delegate:self];
            [self.currentDownloads addObject:download];
            
            [[TCBlobDownloadManager sharedInstance] startDownload:download];
        }
        else {
            for (NSDictionary *downloadInfos in self.defaultDownloads) {
                TCBlobDownloader *download = [[TCBlobDownloader alloc] initWithURL:[NSURL URLWithString:downloadInfos[kURLKey]]
                                                                      downloadPath:kDownloadPath
                                                                          delegate:self];
                [download setFileName:downloadInfos[kNameKey]];
                [self.currentDownloads addObject:download];
                
                [[TCBlobDownloadManager sharedInstance] startDownload:download];
            }
        }
        
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0]
                      withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}


#pragma mark - TCBlobDownloader Delegate


- (void)download:(TCBlobDownloader *)blobDownload didFinishWithSuccess:(BOOL)downloadFinished atPath:(NSString *)pathToFile
{
    NSLog(@"FINISHED");
    NSInteger index = [self.currentDownloads indexOfObject:blobDownload];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index
                                                                                     inSection:0]];
    [cell.detailTextLabel setText:[self subtitleForDownload:blobDownload]];
}

- (void)download:(TCBlobDownloader *)blobDownload
  didReceiveData:(uint64_t)receivedLength
         onTotal:(uint64_t)totalLength
        progress:(float)progress
{
    NSInteger index = [self.currentDownloads indexOfObject:blobDownload];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index
                                                                                     inSection:0]];
    [cell.detailTextLabel setText:[self subtitleForDownload:blobDownload]];
}

- (void)download:(TCBlobDownloader *)blobDownload didReceiveFirstResponse:(NSURLResponse *)response
{
    NSInteger index = [self.currentDownloads indexOfObject:blobDownload];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index
                                                                                     inSection:0]];
    [cell.detailTextLabel setText:[self subtitleForDownload:blobDownload]];
}

- (void)download:(TCBlobDownloader *)blobDownload didStopWithError:(NSError *)error
{
    NSInteger index = [self.currentDownloads indexOfObject:blobDownload];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index
                                                                                     inSection:0]];
    [cell.detailTextLabel setText:[self subtitleForDownload:blobDownload]];
}


#pragma mark - UITableViewDataSource Delegate


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.currentDownloads.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kDownloadCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:kDownloadCellIdentifier];
    }
    
    TCBlobDownloader *download = self.currentDownloads[indexPath.row];
    
    [cell.textLabel setText:download.fileName];
    [cell.textLabel setFont:[UIFont systemFontOfSize:10.f]];
    [cell.detailTextLabel setText:[self subtitleForDownload:download]];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        TCBlobDownloader *download = self.currentDownloads[indexPath.row];
        [download cancelDownloadAndRemoveFile:YES];
        
        NSInteger index = [self.currentDownloads indexOfObject:download];
        
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index
                                                                                         inSection:0]];
        [cell.detailTextLabel setText:[self subtitleForDownload:download]];
        
        [cell setEditing:NO animated:YES];
    }
}


#pragma mark - UITableView Delegate


- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"Cancel";
}

@end
