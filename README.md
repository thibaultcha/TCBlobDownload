# TCBlobDownload

[![Build Status](https://api.travis-ci.org/thibaultCha/TCBlobDownload.png)](https://travis-ci.org/thibaultCha/TCBlobDownload)

This library uses **NSOperations** to download big files (typically videos, music... well: BLOBs) using **NSURLConnection** in background threads. This is a static library, very easy to import in your project and it allows you to pull the latest updates. Installation steps are explained in usage section.

Tested with files from ~150MB to ~1.2GB, mostly videos. It currently only supports ARC.

I've implemented **TCBlobDownload** which extends NSOperation and use **TCBlobDownloadManager** to execute it. You can set a delegate or use blocks (your choice) for each download to update your views etc…

Requires **iOS 5.0 or later**.
  
- **[Features](#features)**
- **[Methods](#methods)**
- **[Usage](#usage)**
- **[Change Log](#change-log)**
- **[Licence](#licence)**

======

## Features
1. Download files in background threads.
2. Use blocks `||` delegate!
3. Pause and resume a download.
4. Set maximum number of concurrent downloads.
5. Custom download path and auto path creation.
6. [download cancelDownloadAndRemoveFile:BOOL]
7. Download dependencies.

## Methods
#### TCBlobDownloadManager
```objective-c
- (TCBlobDownload *)startDownloadWithURL:(NSURL *)url
                downloadPath:(NSString *)customPathOrNil
                 andDelegate:(id<TCBlobDownloadDelegate>)delegateOrNil;

- (TCBlobDownload *)startDownloadWithURL:(NSURL *)url
                downloadPath:(NSString *)customPathOrNil
               firstResponse:(void (^)(NSURLResponse *response))firstResponseBlock
                    progress:(void (^)(float receivedLength, float totalLength))progressBlock
                       error:(void (^)(NSError *error))errorBlock
                    complete:(void (^)(BOOL downloadFinished, NSString *pathToFile))completeBlock;

- (void)startDownload:(TCBlobDownload *)blobDownload;

- (void)setDefaultDownloadDirectory:(NSString *)pathToDL;

- (void)setMaxConcurrentDownloads:(NSInteger)max;

- (NSUInteger)downloadCount;

- (void)cancelAllDownloadsAndRemoveFiles:(BOOL)remove;
```

#### TCBlobDownload
```objective-c
- (id)initWithUrl:(NSURL *)url
     downloadPath:(NSString *)pathToDL // cannot be nil
      andDelegate:(id<TCBlobDownloadDelegate>)delegateOrNil;

- (id)initWithUrl:(NSURL *)url
     downloadPath:(NSString *)pathToDL // cannot be nil
    firstResponse:(void (^)(NSURLResponse *response))firstResponseBlock
         progress:(void (^)(float receivedLength, float totalLength))progressBlock
            error:(void (^)(NSError *error))errorBlock
         complete:(void (^)(BOOL downloadFinished, NSString *pathToFile))completeBlock;

- (void)cancelDownloadAndRemoveFile:(BOOL)remove;

- (void)addDependentDownload:(TCBlobDownload *)blobDownload
```

## Usage
### Import library
1. Drag and drop `TCBlobDownload.xcodeproj` from Finder to your opened project.
2. Open your Project's Target -> Build Phases -> **Target Dependencies** and add `TCBlobDownload`. Then, click **Link binary with libraries** and add `libTCBlobDownload.a` (no worries if it's red).
3. Go to **build settings**, switch "always search user paths" to `YES` and add `$(PROJECT_TEMP_DIR)/../UninstalledProducts/include` to "User Header Search Paths".
4. Import in each file where you want to use the lib. (no worries if no autocomplete)
```
#import <TCBlobDownload/TCBlobDownloadManager.h>
```

### 1. Blocks
Blocks are cool.
To immediately start a download in the default TCBlobDownloadManager directory (`tmp/` by default):

```objective-c
#import "TCBlobDownloadManager.h"

TCBlobDownloadManager *sharedManager = [TCBlobDownloadManager sharedDownloadManager];

TCBlobDownload *downloader = [sharedManager startDownloadWithURL:@"http://give.me/abigfile.avi"
                       downloadPath:nil
                 firstResponse:^(NSURLResponse *response) {
		               // [response expectedContentLength]?
                 }
                 progress:^(float receivedLength, float totalLength){
                   // wow moving progress bar!
                 }
                 error:^(NSError *error){
                   // this not cool
                 }
                 complete:^(BOOL downloadFinished, NSString *pathToFile) {
									// okay
                 }];
```

If you set a customPath:

```objective-c
NSString *customPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"My/Custom/Path/"];

TCBlobDownload *downloader = [sharedManager startDownloadWithURL:@"http://give.me/abigfile.avi"
                  customPathOrNil:customPath // important
                      andDelegate:nil];
```

This will **create** the given path if needed and download the file in the `Path/` directory. **Remember that you should follow the [iOS Data Storage Guidelines](https://developer.apple.com/icloud/documentation/data-storage/)**.

### 2. Delegate
You can either set a delegate which can implement those optional methods if delegates have your preference over blocks:

```objective-c
- (void)download:(TCBlobDownload *)blobDownload didReceiveFirstResponse:(NSURLResponse *)response
{
  // [response expectedContentLength]?
}

- (void)download:(TCBlobDownload *)blobDownload didReceiveData:(uint64_t)received onTotal:(uint64_t)total
{
  // wow moving progress bar! (bis)
}

- (void)download:(TCBlobDownload *)blobDownload didStopWithError:(NSError *)error
{
  // this is not cool
}

- (void)download:(TCBlobDownload *)blobDownload didFinishWithSucces:(BOOL)downloadFinished atPath:(NSString *)pathToFile
{
  // okay, okay
}
```

### 3. Other things you should know
**Cool thing 1:** If a download has been stopped and the local file has not been deleted, when you will restart the download to the same local path, the download will start where it has stopped using the HTTP `Range=bytes` header.

**Cool thing 2:** You can also set dependencies in your downloads using the `addDependentDownload:` method from TCBlobDownload. (See [NSOperation Class Reference](http://developer.apple.com/library/mac/#documentation/Cocoa/Reference/NSOperation_class/Reference/Reference.html) and the `addDependency:` method in particular.)

## Change log
### v1.3.1 (6/01/2013)
* Bug fix

### v1.3 (5/27/2013)
* Removed downloadCancelled and downloadFinished blocks
* Added a completion block : `completeBlock(BOOL downloadFinished, NSString *pathToFile)`
* Updated codestyle

### v1.2 (5/06/2013)
* Now built as a static library
* Download dependencies support
* New block for download cancelled
* New block for first response
* Error localizations

### v1.1 (4/26/2013)
* Blocks support
* Custom download path directory

### v1.0 (4/18/2013)
* Initial release

## Roadmap
If you have any idea or request, please suggest it! :smiley:

* Unit tests
* Cocoapod support
* Multi segmented downloads

## Licence
Copyright (C) 2013 by Thibault Charbonnier.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
