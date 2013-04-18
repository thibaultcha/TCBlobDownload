# BlobDownloader

This class subclasses `NSOperation` to download big files using `NSURLConnection`.

- BlobDownloader: The class to download BLOB files.
- BlobDownloaderQueue: a suggestion for the `NSOperationQueue` implementation. It's a singleton.

## Usage

Just create a `BlobDownloader` instance and add it to a `NSOperationQueue`. See example project.