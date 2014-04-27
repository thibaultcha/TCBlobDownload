//
//  MultipleViewController.m
//  TCBlobDownloadExample
//
//  Created by Albert on 27.04.14.
//  Copyright (c) 2014 thibaultCha. All rights reserved.
//

#import "MultipleViewController.h"

#define kDownloadPath [NSString pathWithComponents:@[NSTemporaryDirectory(), @"multipleExample"]]

@interface MultipleViewController () {
    NSMutableArray *downloads;
}

@end

@implementation MultipleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    downloads = [NSMutableArray new];

    self.title = @"Multiple Downloads Table";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(dismiss)];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showAddDownloadAlert)];
}

- (void)dismiss
{
    [[TCBlobDownloadManager sharedInstance] cancelAllDownloadsAndRemoveFiles:YES];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showAddDownloadAlert
{
    UIAlertView *addAlertView = [[UIAlertView alloc] initWithTitle:@"Add Download" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add this URL", @"~ Multiple Test Downloads ~", nil];
    
    addAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    UITextField *textField = [addAlertView textFieldAtIndex:0];
    textField.placeholder = @"http://";
    
    [addAlertView show];
}

- (void)addDownload:(NSURL *)url
{
    TCBlobDownloader *download = [[TCBlobDownloader alloc] initWithURL:url downloadPath:kDownloadPath delegate:self];
    
    download.fileName = [url.absoluteString lastPathComponent];
    
    [[TCBlobDownloadManager sharedInstance] startDownload:download];
    
    [downloads addObject:download];
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Helper Methods

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

#pragma mark - Alert view delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex) {
        
        if (buttonIndex == 0) {
            NSString *urlString = [alertView textFieldAtIndex:0].text;
            
            [self addDownload:[NSURL URLWithString:urlString]];
        }
        else {
            [self addDownload:[NSURL URLWithString:@"http://api.soundcloud.com/tracks/136369443/stream?client_id=b45b1aa10f1ac2941910a7f0d10f8e28"]];
            [self addDownload:[NSURL URLWithString:@"http://api.soundcloud.com/tracks/130355303/stream?client_id=b45b1aa10f1ac2941910a7f0d10f8e28"]];
            [self addDownload:[NSURL URLWithString:@"https://api.soundcloud.com/tracks/126240832/download?client_id=b45b1aa10f1ac2941910a7f0d10f8e28"]];
        }
        
    }
}

#pragma mark - Blob downloader delegate

- (void)download:(TCBlobDownloader *)blobDownload didFinishWithSuccess:(BOOL)downloadFinished atPath:(NSString *)pathToFile
{
    NSInteger index = [downloads indexOfObject:blobDownload];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    cell.detailTextLabel.text = [self subtitleForDownload:blobDownload];
}

- (void)download:(TCBlobDownloader *)blobDownload didReceiveData:(uint64_t)receivedLength onTotal:(uint64_t)totalLength progress:(float)progress
{
    NSInteger index = [downloads indexOfObject:blobDownload];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    cell.detailTextLabel.text = [self subtitleForDownload:blobDownload];
}

- (void)download:(TCBlobDownloader *)blobDownload didReceiveFirstResponse:(NSURLResponse *)response
{
    NSInteger index = [downloads indexOfObject:blobDownload];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    cell.detailTextLabel.text = [self subtitleForDownload:blobDownload];
}

- (void)download:(TCBlobDownloader *)blobDownload didStopWithError:(NSError *)error
{
    NSInteger index = [downloads indexOfObject:blobDownload];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    cell.detailTextLabel.text = [self subtitleForDownload:blobDownload];
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return downloads.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    
    TCBlobDownloader *download = downloads[indexPath.row];
    
    cell.textLabel.text = download.fileName;
    
    cell.detailTextLabel.text = [self subtitleForDownload:download];
    
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        TCBlobDownloader *download = downloads[indexPath.row];
        [download cancelDownloadAndRemoveFile:YES];
        
        NSInteger index = [downloads indexOfObject:download];
        
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        cell.detailTextLabel.text = [self subtitleForDownload:download];
        
        [cell setEditing:NO animated:YES];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"Cancel";
}

@end
