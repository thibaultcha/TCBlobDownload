# TCBlobDownload

[![Build Status](https://api.travis-ci.org/thibaultCha/TCBlobDownload.png)](https://travis-ci.org/thibaultCha/TCBlobDownload)
[![Pod version](https://cocoapod-badges.herokuapp.com/v/TCBlobDownload/badge.png)](https://cocoapod-badges.herokuapp.com/v/TCBlobDownload/badge.png)
[![Pod platform](https://cocoapod-badges.herokuapp.com/p/TCBlobDownload/badge.png)](https://cocoapod-badges.herokuapp.com/p/TCBlobDownload/badge.png)

TCBlobDownload uses **NSOperations** to download large files (typically videos, music... well: BLOBs) using **NSURLConnection** in background threads.

Tested with files from ~150MB to ~1.2GB, mostly videos.

I've implemented **TCBlobDownloader** which extends NSOperation and use **TCBlobDownloadManager** to execute it. You can set a delegate or use blocks (your choice) for each download to update your views etc…

Requires **iOS 5.1.1 or later** and ARC.
  
- **[Features](#features)**
- **[Documentation](#documentation-books)**
- **[Installation](#installation)**
- **[Example](#example-eyeglasses)**
- **[Change Log](#change-log-memo)**
- **[Roadmap](#roadmap-rocket)**

======

## Features
1. Download files in background threads
2. Blocks or delegate style
3. Pause and resume a download
4. Set maximum number of concurrent downloads
5. Custom download path and auto path creation
6. Download speed and remaining time 
7. Download cancellation
8. Download dependencies

## Documentation :books:

Browse the documentation on [Cocoadocs](http://cocoadocs.org/docsets/TCBlobDownload) or add it directly to Xcode by [downloading](https://github.com/thibaultCha/TCBlobDownload/blob/master/TCBlobDownload/Docs/TCBlobDownloadDocset.zip?raw=true) the docset and placing it into `~/Library/Developer/Shared/Documentation/DocSets/`. (or use [Dash](http://kapeli.com/dash))

## Installation

### CocoaPods

Add the following to your Podfile and run `$ pod install`:

```ruby
pod 'TCBlobDownload'
```

If you don't have CocoaPods installed or integrated into your project, you can learn how to do so [here](http://cocoapods.org).

(Also be sure the `$(inherited)` flag is set in your `Project's Target -> Build Settings -> Other Linker Flags`)

### Import as a static library

1. Drag and drop `TCBlobDownload.xcodeproj` from Finder to your opened project.
2. Project's Target -> Build Phases -> **Target Dependencies** -> add `TCBlobDownload`. Then, click **Link binary with libraries** and add `libTCBlobDownload.a` (no worries if it's red).
3. Go to **build settings**, switch "always search user paths" to `YES` and add `$(PROJECT_TEMP_DIR)/../UninstalledProducts/include` to "User Header Search Paths".
4. Project's Target -> Build Settings -> **Other Linker Flags** -> Add `-ObjC`
4. Import the lib. (no worries if no autocomplete)
```
#import <TCBlobDownload/TCBlobDownload.h>
```

## Examples :eyeglasses:

### 1. Blocks
Blocks are cool.
To immediately start a download in the default TCBlobDownloadManager directory (`tmp/` by default):

```objective-c
TCBlobDownloadManager *sharedManager = [TCBlobDownloadManager sharedInstance];

TCBlobDownloader *downloader = [sharedManager startDownloadWithURL:@"http://give.me/abigfile.avi"
                downloadPath:nil
                 firstResponse:^(NSURLResponse *response) {
		      
                 }
                 progress:^(float receivedLength, float totalLength, NSInteger remainingTime){
                   // wow moving progress bar!
                 }
                 error:^(NSError *error){
                  // this not cool
                 }
                 complete:^(BOOL downloadFinished, NSString *pathToFile) {
                  // okay
                 }];
```

If you set a custom path:

```objective-c
NSString *customPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"My/Custom/Path/"];

TCBlobDownloader *downloader = [sharedManager startDownloadWithURL:@"http://give.me/abigfile.avi"
                                                            customPath:customPath // important
                                                           andDelegate:nil];
```

This will **create** the given path if needed and download the file in the `Path/` directory. Please note that during the download process you have no control over the file name as explained with reasons why in the documentation. **Remember that you should follow the [iOS Data Storage Guidelines](https://developer.apple.com/icloud/documentation/data-storage/)**.

### 2. Delegate
You can either set a delegate which can implement those optional methods if delegates have your preference over blocks:

```objective-c
- (void)download:(TCBlobDownloader *)blobDownload didReceiveFirstResponse:(NSURLResponse *)response
{

}

- (void)download:(TCBlobDownloader *)blobDownload didReceiveData:(uint64_t)received onTotal:(uint64_t)total
{
  // wow moving progress bar! (bis)
  // blobDownload.remainingTime
  // blobDownload.speedRate
}

- (void)download:(TCBlobDownloader *)blobDownload didStopWithError:(NSError *)error
{
  // this is not cool
}

- (void)download:(TCBlobDownloader *)blobDownload didFinishWithSucces:(BOOL)downloadFinished atPath:(NSString *)pathToFile
{
  // okay, okay
}
```

### 3. Other things you should know
**Cool thing 1:** If a download has been stopped and the local file has not been deleted, when you will restart the download to the same local path, the download will start where it has stopped using the HTTP [Range](http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html) header (14.35).

**Cool thing 2:** You can also set dependencies in your downloads using the `addDependentDownload:` method from `TCBlobDownloader`.

See [documentation](#documentation-books) for more details.

## Change log :memo:

### v1.5.1 (7/04/2014)
* Important fix for [#21](https://github.com/thibaultCha/TCBlobDownload/issues/21)

### v1.5 (8/03/2014)
* Improved documentation and created a docset
* Added a `speedRate` and `remainingTime` (in seconds) property on `TCBlobDownloader` thanks to [#16](https://github.com/thibaultCha/TCBlobDownload/issues/16)
* Updated `TCBlobDownloader` properties to `readonly`
* Refactored code and tests for a much more maintainable code base

### v1.4 (11/19/2013)
* Unit testing
* HTTP error status code handling [#3](https://github.com/thibaultCha/TCBlobDownload/pull/3)
* Manager returns created downloads [#5](https://github.com/thibaultCha/TCBlobDownload/pull/5)
* Cocoapods release

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

## Roadmap :rocket:
If you have any idea or request, please suggest it! :smiley:

* Multi segmented downloads
* Dash XML feed for documentation versioning
