## Changelog :memo:

## [2.1.1] - 2015/02/22
#### Added
- Progress resumes at correct rate after resuming a download

## [2.1.0] - 2015/01/03
#### Added
- Expose `TCBlobDownloadErrorDomain`
- Remove `TCBlobDownloadErrorConnectionFailed` and directly return the `NSURLErrorDomain` error in case of connection failure
- Better handling of the `NSOperation` states

#### Fixed
- Crash on calling `sharedInstance` [#47](https://github.com/thibaultCha/TCBlobDownload/issues/47)
- Travis tests not executing

## [2.0.1] - 2015/01/01
#### Added
- The `TCBlobDownloadManager` sharedInstance's `NSOperationQueue` is named
- Small documentation updates

#### Fixed
- A warning regarding a property's attribute in `TCBlobDownload`

## [2.0.0] - 2014/12/16
#### Added
- **Breaking**: changed `setDefaultDownloadPath:` to `setDefaultDownloadPath:error:`
- Expose the underlying `NSURLRequest`
- Improve directory management

#### Fixed
- Threads management issue [#30](https://github.com/thibaultCha/TCBlobDownload/issues/30), [#41](https://github.com/thibaultCha/TCBlobDownload/issues/41)
- Example app issue

## [1.5.2] - 2014/05/08
#### Added
Thanks to [#26](https://github.com/thibaultCha/TCBlobDownload/issues/26),
- Instances of `TCBlobDownloader` now have a state property
- The example project has now a multiple downloads example

## [1.5.1] - 2014/04/07
#### Fixed
- Important fix for [#21](https://github.com/thibaultCha/TCBlobDownload/issues/21)

## [1.5] - 2014/03/08
#### Added
- Improved documentation and created a docset
- Added a `speedRate` and `remainingTime` (in seconds) property on `TCBlobDownloader` thanks to [#16](https://github.com/thibaultCha/TCBlobDownload/issues/16)
- Updated `TCBlobDownloader` properties to `readonly`
- Refactored code and tests for a much more maintainable code base

## [1.4] - 2013/11/19
#### Added
- Unit testing
- HTTP error status code handling [#3](https://github.com/thibaultCha/TCBlobDownload/pull/3)
- Manager returns created downloads [#5](https://github.com/thibaultCha/TCBlobDownload/pull/5)
- Cocoapods release

## [1.3.1] - 2013/06/01
#### Fixed
- Fix `NotEnoughFreeSpace` error being fired erroneously

## [1.3] - 2013/05/27
#### Added
- Added a completion block : `completeBlock(BOOL downloadFinished, NSString -pathToFile)`
- Removed `downloadCancelled` and @downloadFinished` blocks
- Updated codestyle

## [1.2] - 2013/05/06
#### Added
- Now built as a static library
- Download dependencies support
- New block for download cancelled
- New block for first response
- Error localizations

## 1.1 - 2013/04/26
#### Added
- Blocks support
- Custom download path directory

## 1.0 - 2013/04/18
- Initial release

[2.1.1]: https://github.com/thibaultCha/TCBlobDownload/compare/2.1.0...2.1.1
[2.1.0]: https://github.com/thibaultCha/TCBlobDownload/compare/2.0.1...2.1.0
[2.0.1]: https://github.com/thibaultCha/TCBlobDownload/compare/2.0.0...2.0.1
[2.0.0]: https://github.com/thibaultCha/TCBlobDownload/compare/1.5.2...2.0.0
[1.5.2]: https://github.com/thibaultCha/TCBlobDownload/compare/1.5.1...1.5.2
[1.5.1]: https://github.com/thibaultCha/TCBlobDownload/compare/1.5...1.5.1
[1.5]: https://github.com/thibaultCha/TCBlobDownload/compare/1.4...1.5
[1.4]: https://github.com/thibaultCha/TCBlobDownload/compare/1.3.1...1.4
[1.3.1]: https://github.com/thibaultCha/TCBlobDownload/compare/1.3...1.3.1
[1.3]: https://github.com/thibaultCha/TCBlobDownload/compare/1.2...1.3
[1.2]: https://github.com/thibaultCha/TCBlobDownload/compare/1.1...1.2
