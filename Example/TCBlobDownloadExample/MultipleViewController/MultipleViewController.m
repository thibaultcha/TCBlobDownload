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

@interface MultipleViewController ()
@property (nonatomic, strong) NSMutableArray *downloads;
- (void)dismiss:(id)sender;
- (void)showAddDownloadAlert:(id)sender;
- (void)addDownload:(NSURL *)url;
- (NSString *)subtitleForDownload:(TCBlobDownloader *)download;
@end

@implementation MultipleViewController


#pragma mark - View Lifecycle


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _downloads = [NSMutableArray new];

    [self setTitle:@"Multiple Downloads Table"];
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

- (void)addDownload:(NSURL *)url
{
    TCBlobDownloader *download = [[TCBlobDownloader alloc] initWithURL:url
                                                          downloadPath:kDownloadPath
                                                              delegate:self];
    //[download setFileName:[url.absoluteString lastPathComponent]];
    
    [[TCBlobDownloadManager sharedInstance] startDownload:download];
    
    [self.downloads addObject:download];
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0]
                  withRowAnimation:UITableViewRowAnimationAutomatic];
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
    
    return [NSString stringWithFormat:@"%i%% • %lis left • State: %@", (int)(download.progress * 100), (long)download.remainingTime, stateString];
}


#pragma mark - UIAlertView Delegate


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex) {
        if (buttonIndex == 0) {
            NSString *urlString = [alertView textFieldAtIndex:0].text;
            
            [self addDownload:[NSURL URLWithString:urlString]];
        }
        else {
            [self addDownload:[NSURL URLWithString:@"https://api.soundcloud.com/tracks/136369443/stream?client_id=b45b1aa10f1ac2941910a7f0d10f8e28"]];
            [self addDownload:[NSURL URLWithString:@"https://api.soundcloud.com/tracks/130355303/stream?client_id=b45b1aa10f1ac2941910a7f0d10f8e28"]];
            [self addDownload:[NSURL URLWithString:@"https://api.soundcloud.com/tracks/126240832/download?client_id=b45b1aa10f1ac2941910a7f0d10f8e28"]];
        }
    }
}


#pragma mark - TCBlobDownloader Delegate


- (void)download:(TCBlobDownloader *)blobDownload didFinishWithSuccess:(BOOL)downloadFinished atPath:(NSString *)pathToFile
{
    NSInteger index = [self.downloads indexOfObject:blobDownload];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index
                                                                                     inSection:0]];
    [cell.detailTextLabel setText:[self subtitleForDownload:blobDownload]];
}

- (void)download:(TCBlobDownloader *)blobDownload
  didReceiveData:(uint64_t)receivedLength
         onTotal:(uint64_t)totalLength
        progress:(float)progress
{
    NSInteger index = [self.downloads indexOfObject:blobDownload];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index
                                                                                     inSection:0]];
    [cell.detailTextLabel setText:[self subtitleForDownload:blobDownload]];
}

- (void)download:(TCBlobDownloader *)blobDownload didReceiveFirstResponse:(NSURLResponse *)response
{
    NSInteger index = [self.downloads indexOfObject:blobDownload];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index
                                                                                     inSection:0]];
    [cell.detailTextLabel setText:[self subtitleForDownload:blobDownload]];
}

- (void)download:(TCBlobDownloader *)blobDownload didStopWithError:(NSError *)error
{
    NSInteger index = [self.downloads indexOfObject:blobDownload];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index
                                                                                     inSection:0]];
    [cell.detailTextLabel setText:[self subtitleForDownload:blobDownload]];
}


#pragma mark - UITableViewDataSource Delegate


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.downloads.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kDownloadCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:kDownloadCellIdentifier];
    }
    
    TCBlobDownloader *download = self.downloads[indexPath.row];
    
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
        TCBlobDownloader *download = self.downloads[indexPath.row];
        [download cancelDownloadAndRemoveFile:YES];
        
        NSInteger index = [self.downloads indexOfObject:download];
        
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
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
