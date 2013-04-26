# TCBlobDownload
This little library uses **NSOperations** to download big files using **NSURLConnection** in background threads.

I've implemented **TCBlobDownload** which extends NSOperation and use **TCBlobDownloadManager** to execute it. You can set a delegate or use blocks (your choice) for each download to update your views etc…

I've tested it with files from ~150MB to ~700MB, mostly videos.

Requires **iOS 5.0 or greater**.

It currently only supports ARC but I hope to make a non-ARC implementation soon.

## Features
1. Download files in background threads.
2. Use blocks `||` delegate!
3. Pause and resume later a download.
4. Set maximum number of concurrent downloads.
5. Custom download path and auto path creation.
6. [download cancelDownloadAndRemoveFile:BOOL]

Dependencies and more...

## Methods
#### TCBlobDownloadManager
```objective-c
- (void)startDownloadWithURL:(NSString *)urlString
                downloadPath:(NSString *)customPathOrNil
                 andDelegate:(id<TCBlobDownloadDelegate>)delegateOrNil;

- (void)startDownloadWithURL:(NSString *)urlString
                downloadPath:(NSString *)customPathOrNil
               progressBlock:(void (^)(float receivedLength, float totalLength))progressBlock
                  errorBlock:(void (^)(NSError *error))errorBlock
             completionBlock:(void (^)())completionBlock;

- (void)startDownload:(TCBlobDownload *)blobDownload;

- (void)setDefaultDownloadDirectory:(NSString *)pathToDL;

- (void)setMaxConcurrentDownloads:(NSInteger)max;

- (NSUInteger)downloadCount;

- (void)cancelAllDownloadsAndRemoveFiles:(BOOL)remove;
```

#### TCBlobDownload
```objective-c
- (id)initWithUrlString:(NSString *)urlString
           downloadPath:(NSString *)pathToDL // cannot be nil
            andDelegate:(id<TCBlobDownloadDelegate>)delegateOrNil;

- (id)initWithUrlString:(NSString *)urlString // cannot be nil
           downloadPath:(NSString *)pathToDL
          progressBlock:(void (^)(float receivedLength, float totalLength))progressBlock
             errorBlock:(void (^)(NSError *error))errorBlock
        completionBlock:(void (^)())completionBlock;

- (void)cancelDownloadAndRemoveFile:(BOOL)remove;
```

## Usage
### 1. Blocks
Blocks are cool.
To immediately start a download in the default TCBlobDownloadManager directory (`tmp/` by default):

```objective-c
#import "TCBlobDownloadManager.h"

TCBlobDownloadManager *sharedManager = [TCBlobDownloadManager sharedDownloadManager];

[sharedManager startDownloadWithURL:@"http://give.me/bigfile.avi"
                       downloadPath:nil
                      progressBlock:^(float receivedLength, float totalLength){
                   // wow moving progress bar!
                 }
                       errorBlock:^(NSError *error){
                   // this not cool
                 }
                       completionBlock:^{
                   // this is cool
                 }];
```

If you set a customPath:

```objective-c
NSString *customPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"My/Custom/Path/"];
[sharedManager addDownloadWithURL:@"http://give.me/bigfile.avi"
                  customPathOrNil:customPath // important
                      andDelegate:nil];
```
 
This will **create** the given path if needed and download the file in the `Path/` directory. **Remember that you should follow the [iOS Data Storage Guidelines](https://developer.apple.com/icloud/documentation/data-storage/)**.

### 2. Delegate
You can either set a delegate which can implement those optional methods if delegates have your preference over blocks:

```objective-c
- (void)download:(TCBlobDownload *)blobDownload didReceiveData:(uint64_t)received onTotal:(uint64_t)total
{
  // wow moving progress bar! (bis)
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

### 3. Other things you should know
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