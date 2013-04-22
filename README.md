# BlobDownloadManager

This little library uses `NSOperationQueue` to download big files using `NSURLConnection`.

I've created `BlobDownloader` which extends `NSOperation` and use `BlobDownloadManager` to execute it. You can set a delegate for each `BlobDownloader` to update your views etc…

However, BlobDL does not provide a way to store executing downloads, and it's up to you to choose how to store them, and how you retrieve them in their delegate. Better explanation in usage section.

## Features
1. Download files in background threads.
2. Pause and resume later a download.
3. Set maximum number of concurrent downloads.
4. Keep trace of your downloads using delegates and update your UI.
5. Custom download path.
6. [BlobDownloader endDownloadAndRemoveFile:BOOL]

## Methods
```objective-c
// BlobDownloadManager
- (BlobDownloader *)addDownloadWithURL:(NSString *)urlString
             customDownloadDirectory:(NSString *)customPathOrNil
                         andDelegate:(id<BlobDownloadManagerDelegate>)delegateOrNil;

- (void)setDefaultDownloadDirectory:(NSString *)pathToDL;

- (void)setMaxConcurrentDownloads:(NSInteger)max;

- (NSUInteger)downloadCount;

- (void)cancelAllDownloadsAndRemoveFiles:(BOOL)remove;

// BlobDownloader
- (void)endDownloadAndRemoveFile;
```

## Usage
### Wild download (No delegate)

```objective-c
#import "BlobDownloadManager.h"

BlobDownloadManager *sharedManager = [BlobDownloadManager sharedDownloadManager];

[sharedManager addDownloadWithURL:@"http://give.me/bigfile.avi"
									customPathOrNil:nil
                      andDelegate:nil];
```

This way, your download will start and you'll see the progress in the console. It will be downloaded in the default download directory (`Documents/` if not set).

Note that:

```objective-c
NSString *customPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/My/Custom/Path/"];
[sharedManager addDownloadWithURL:@"http://give.me/bigfile.avi"
									customPathOrNil:customPath
                      andDelegate:nil];
```
 
Will create the given path and download the file in the `Path/` directory.

### BlobDL and delegates
If you want to update your UI, you can set a delegate which can implement those optional methods:

```objective-c
- (void)downloader:(BlobDownloader *)blobDownloader
  didReceiveData:(uint64_t)received
         onTotal:(uint64_t)total
{

}

- (void)downloadDidFinishWithDownloader:(BlobDownloader *)blobDownloader
{

}

- (void)downloader:(BlobDownloader *)blobDownloader didStopWithError:(NSError *)error
{

}
```

And the usage becomes:

```objective-c
BlobDownloader *blobDL = [sharedManager addDownloadWithURL:@"http://give.me/bigfile.avi"
customDownloadDirectory:nil
            andDelegate:delegate];
// Store blobDL the way you want to retrieve it in delegate methods
```

Then, if your add multiple downloads to the Manager, you must 
find a way to store the created `BlobDownloaders`. **For example, to update UIProgressViews in UITableViewCells, I used a NSMutableDictionnary using the cell's indexPath as key.** I may update the lib example later, and it would come with a screenshot and that would be nice.

### Other things you should know
Store your `BlobDownloaders` allows you to do:

```objective-c
BlobDownloader *blobDL = [sharedManager addDownloadWithURL:@"http://give.me/bigfile.avi" customDownloadDirectory: nil
       andDelegate:delegate];

[BlobDownloader endDownloadAndRemoveFile:YES]
```

And access to its file name, file path and URL address. Blah blah blah.

**Cool thing:** if a download has been stopped and the local file has not been deleted, when you will restart the download to the same local path, the download will start where it has stopped using the HTTP `Range=bytes` header.

**Cool thing 2:** You can also set dependencies in your downloads. See [NSOperation Class Reference](http://developer.apple.com/library/mac/#documentation/Cocoa/Reference/NSOperation_class/Reference/Reference.html) and the `addDependency:` method in particular.

## Roadmap
It would be **great** to handle the BlobDL storage thing and let your mind free of that, but I did not find a way yet, or ugly ones I think. If you have any idea, please suggest it! :)

- Solve the BlobDL storage thing
- Encapsulate dependencies

## Licence

```
Copyright (C) 2013 by Thibault Charbonnier.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
```