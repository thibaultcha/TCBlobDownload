//
//  ViewController.m
//  BlobDownloaderExample
//
//  Created by Thibault Charbonnier on 18/04/13.
//  Copyright (c) 2013 thibaultCha. All rights reserved.
//

#import "ViewController.h"

#define BYTES_TO_MB(X) (float)((X/1024)/1024)
#define BYTES_TO_GB(X) (float)(((X/1024)/1024)/1024)

@implementation ViewController


#pragma mark - Init


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.sharedDownloadManager = [TCBlobDownloadManager sharedDownloadManager];
        self.fileManager = [NSFileManager defaultManager];
        self.contents = [self.fileManager contentsOfDirectoryAtPath:DEFAULT_PATH error:NULL];
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

-(IBAction)touchBackground:(id)sender
{
    [self.urlField resignFirstResponder];
}

-(IBAction)removeAll:(id)sender
{
    NSMutableString *logMessage = [NSMutableString new];
    
    for (NSString *fileName in self.contents) {
        NSMutableString *filePath = [NSMutableString new];
        [filePath appendString:DEFAULT_PATH];
        [filePath appendString:@"/"];
        [filePath appendString:fileName];
        BOOL result = [self.fileManager removeItemAtPath:filePath error:nil];
        
        if (result) {
            [logMessage appendString:[NSString stringWithFormat:@"%@ is deleted\n", fileName]];
        }
    }
    
    [self.logTextView setText:logMessage];
    self.contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:DEFAULT_PATH error:NULL];
}

-(void)addLogOnTextView:(NSString *)addLog
{
    NSMutableString *logString = [NSMutableString new];
    [logString appendString:self.logTextView.text];
    [logString appendString:addLog];
    [self.logTextView setText:logString];
}


#pragma mark - Demo


- (void)download:(id)sender
{
    _printCount = 0;
    
    // Delegate
    /*[self.sharedDownloadManager startDownloadWithURL:[NSURL URLWithString:downloadStr]
     customPath:nil
     delegate:self];*/
    
    
    
    // How to use Blocks
    FirstResponseBlock firstBlock = ^(NSURLResponse *response) {
        
        NSLog(@"%lld", [response expectedContentLength]);
        NSLog(@"%@", [response suggestedFilename]);
        NSLog(@"%@", [response MIMEType]);
        NSLog(@"%@", [response textEncodingName]);
        NSLog(@"%@", [response URL]);
    };
    
    ProgressBlock progressBlock = ^(float receivedLength, float totalLength) {
        
        if (_printCount%500 == 0) {
            [self addLogOnTextView:[self getProgressingMessageReceived:receivedLength andTotal:totalLength]];
        }
        
        [_progressView setProgress:(float)(receivedLength/totalLength) animated:YES];
        _printCount++;
    };
    
    ErrorBlock errorBlock = ^(NSError *error) {
        
        [self addLogOnTextView:[NSString stringWithFormat:@"\n\nERROR : %@", error.description]];
    };
    
    CompleteBlock completeBlock = ^(BOOL downloadFinished, NSString *pathToFile) {
        
        if (downloadFinished == YES) {
            
            [self addLogOnTextView:[NSString stringWithFormat:@"\n\nDowload Complete... 100%% \n - path to file : %@", pathToFile]];
            self.contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:DEFAULT_PATH error:NULL];
        }
    };
    
    // Blocks
    [self.sharedDownloadManager startDownloadWithURL:[NSURL URLWithString:self.urlField.text]
                                          customPath:nil
                                       firstResponse:firstBlock
                                            progress:progressBlock
                                               error:errorBlock
                                            complete:completeBlock];
    [self.urlField resignFirstResponder];
}

- (void)cancelAll:(id)sender
{
    [self.sharedDownloadManager cancelAllDownloadsAndRemoveFiles:YES];
    
    [self addLogOnTextView: @"\nDownload is canceled"];
}

- (NSString *)getProgressingMessageReceived:(float)receivedLength andTotal:(float)totalLength
{
    NSMutableString *message = [NSMutableString new];
    
    [message appendString:[NSString stringWithFormat:@"\nDowloading... %.2f%%", (float)(receivedLength/totalLength)* 100]];
    
    if (BYTES_TO_MB(receivedLength) < 1000.0) {
        [message appendString:[NSString stringWithFormat:@"\n - Received: %.2fMB", BYTES_TO_MB(receivedLength)]];
    } else {
        [message appendString:[NSString stringWithFormat:@"\n - Received: %.2fGB", BYTES_TO_GB(receivedLength)]];
    }
    
    if (BYTES_TO_MB(totalLength) < 1000.0) {
        [message appendString:[NSString stringWithFormat:@" - Total: %.2fMB", BYTES_TO_MB(totalLength)]];
    } else {
        [message appendString:[NSString stringWithFormat:@" - Total: %.2fGB", BYTES_TO_GB(totalLength)]];
    }
    
    return message;
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

- (void)download:(TCBlobDownload *)blobDownload didCancelRemovingFile:(BOOL)fileRemoved
{
    
}

- (void)download:(TCBlobDownload *)blobDownload didFinishWithSucces:(BOOL)downloadFinished atPath:(NSString *)pathToFile
{
}


#pragma mark - Table Data source & delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    self.contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:DEFAULT_PATH error:NULL];
    
    return [self.contents count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"contentItem"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"contentItem"];
    }
    
    [cell.textLabel setText:self.contents[indexPath.row]];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    [cell setSelected:NO];
}


@end
