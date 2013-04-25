# TCBlobDownload
This little library uses `NSOperations` to download big files using `NSURLConnection` in background threads with `NSOperationQueue`.

I've implemented `TCBlobDownload` which extends `NSOperation` and use `TCBlobDownloadManager` to execute it. You can set a delegate for each `TCBlobDownload` to update your views etc…

I've tested it with files from ~150MB to ~700MB, mostly videos.

It currently only supports ARC but I hope to make a non-ARC implementation soon.

## Features
1. Download files in background threads.
2. Pause and resume later a download.
3. Set maximum number of concurrent downloads.
4. Update your UI with delegates.
5. Custom download path and auto path creation.
6. [download cancelDownloadAndRemoveFile:BOOL]

Dependencies and more...

### Methods
```objective-c
// TCBlobDownloadManager
- (void)addDownloadWithURL:(NSString *)urlString
  customDownloadDirectory:(NSString *)customPathOrNil
              andDelegate:(id<TCBlobDownloadDelegate>)delegateOrNil;

- (void)addDownload:(TCBlobDownload *)blobDownload;

- (void)setDefaultDownloadDirectory:(NSString *)pathToDL;

- (void)setMaxConcurrentDownloads:(NSInteger)max;

- (NSUInteger)downloadCount;

- (void)cancelAllDownloadsAndRemoveFiles:(BOOL)remove;

// TCBlobDownload
- (id)initWithUrlString:(NSString *)urlString
           downloadPath:(NSString *)pathToDL // cannot be nil
            andDelegate:(id<TCBlobDownloadDelegate>)delegateOrNil;

- (void)cancelDownloadAndRemoveFile;
```

## Usage
### Wild download (No delegate)

```objective-c
#import "TCBlobDownloadManager.h"

TCBlobDownloadManager *sharedManager = [TCBlobDownloadManager sharedDownloadManager];

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

### TCBlobDownloadDelegate
If you want to update your UI, you can set a delegate which can implement those optional methods:

```objective-c
- (void)download:(TCBlobDownload *)blobDownload didReceiveData:(uint64_t)received onTotal:(uint64_t)total
{
  // wow moving progress bar!
}

- (void)downloadDidFinishWithDownload:(TCBlobDownload *)blobDownload
{
  // this is cool
}

- (void)download:(TCBlobDownload *)blobDownload didStopWithError:(NSError *)error
{
  // this is not cool
}
```

### Other things you should know
**Cool thing 1:** If a download has been stopped and the local file has not been deleted, when you will restart the download to the same local path, the download will start where it has stopped using the HTTP `Range=bytes` header.

**Cool thing 2:** You can also set dependencies in your downloads. See [NSOperation Class Reference](http://developer.apple.com/library/mac/#documentation/Cocoa/Reference/NSOperation_class/Reference/Reference.html) and the `addDependency:` method in particular.

## Roadmap
If you have any idea, please suggest it! :)

- Encapsulate dependencies

## Licence

```
Copyright (C) 2013 by Thibault Charbonnier.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
```