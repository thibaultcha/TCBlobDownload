## Changelog :memo:

### 2.0.0 (16/12/2014)
* **Breaking**: changed `setDefaultDownloadPath:` to `setDefaultDownloadPath:error:`
* Fix threads management issue [#30](https://github.com/thibaultCha/TCBlobDownload/issues/30), [#41](https://github.com/thibaultCha/TCBlobDownload/issues/41)
* Expose the underlying `NSURLRequest`
* Improve directory management
* Fix example app

### 1.5.2 (08/05/2014)
Thanks to [#26](https://github.com/thibaultCha/TCBlobDownload/issues/26),
* Instances of `TCBlobDownloader` now have a state property
* The example project has now a multiple downloads example

### 1.5.1 (07/04/2014)
* Important fix for [#21](https://github.com/thibaultCha/TCBlobDownload/issues/21)

### 1.5 (08/03/2014)
* Improved documentation and created a docset
* Added a `speedRate` and `remainingTime` (in seconds) property on `TCBlobDownloader` thanks to [#16](https://github.com/thibaultCha/TCBlobDownload/issues/16)
* Updated `TCBlobDownloader` properties to `readonly`
* Refactored code and tests for a much more maintainable code base

### 1.4 (19/11/2013)
* Unit testing
* HTTP error status code handling [#3](https://github.com/thibaultCha/TCBlobDownload/pull/3)
* Manager returns created downloads [#5](https://github.com/thibaultCha/TCBlobDownload/pull/5)
* Cocoapods release

### 1.3.1 (01/06/2013)
* Bug fix

### 1.3 (27/05/2013)
* Removed downloadCancelled and downloadFinished blocks
* Added a completion block : `completeBlock(BOOL downloadFinished, NSString *pathToFile)`
* Updated codestyle

### 1.2 (06/05/2013)
* Now built as a static library
* Download dependencies support
* New block for download cancelled
* New block for first response
* Error localizations

### 1.1 (26/04/2013)
* Blocks support
* Custom download path directory

### 1.0 (18/04/2013)
* Initial release
