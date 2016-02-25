//
//  OTHTTPDownloadRequest.h
//  DownloadTest
//
//  Created by openthread on 12/17/12.
//  Copyright (c) 2012 openthread. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OTHTTPDownloadRequest;

#pragma mark - Delegate

@protocol OTHTTPDownloadRequestDelegate <NSObject>

@optional

/**
 *  Download successed
 *
 *  @param request The downloading request instance
 */
- (void)downloadRequestFinished:(OTHTTPDownloadRequest *)request;

/**
 *  Download failed
 *
 *  @param request The downloading request instance
 *  @param error   Error for failing.
 */
- (void)downloadRequestFailed:(OTHTTPDownloadRequest *)request error:(NSError *)error;

/**
 *  Write file failed, due to disk full or other reason. With a system exception callback.
 *
 *  @param request   The downloading request instance
 *  @param exception The exception object for writing file failed
 */
- (void)downloadRequestWriteFileFailed:(OTHTTPDownloadRequest *)request exception:(NSException *)exception;

/*
 Response received. If block thread in this method, data transfer will be block too.
 You can cancel download request if receivced a unexpected response in this method.
 */
- (void)downloadRequestReceivedResponse:(OTHTTPDownloadRequest *)request;

/**
 *  Downloaded data callback
 *
 *  @param request          The downloading request instance
 *  @param progress         Current progress
 *  @param bytesPerSecond   Current speed, bytes per second
 *  @param totalReceived    Total received content size in cache file
 *  @param expectedDataSize Expected file size from http response header
 */
- (void)downloadRequest:(OTHTTPDownloadRequest *)request
 currentProgressUpdated:(float)progress
                  speed:(float)bytesPerSecond
          totalReceived:(unsigned long long)totalReceived
       expectedDataSize:(unsigned long long)expectedDataSize;

@end

#pragma mark - Interface

@interface OTHTTPDownloadRequest : NSObject

#pragma mark Init

/**
 *  Create a file download request. Default timeout interval is 15 seconds.
 *
 *  @param urlString        The downloading url string.
 *  @param cacheFile        The file path for caching. If cache file exist, new content will append to this cache file (this behavior is to continue last paused downloading).
 *  @param finishedFilePath The file path to save the downloading finished file.
 *  @param delegate         The callback delegate.
 *
 *  @return The created request instance.
 */
- (id)initWithURL:(NSString *)urlString
        cacheFile:(NSString *)cacheFile
 finishedFilePath:(NSString *)finishedFilePath;

#pragma mark Properties

@property (nonatomic, weak) id<OTHTTPDownloadRequestDelegate> delegate;
@property (nonatomic, strong) id userInfo;

/**
 *  Check response Status Code. If haven't receive response yet, return NSNotFound
 */
@property (nonatomic, readonly) NSUInteger responseStatusCode;

/**
 *  Check response MIME type. If haven't receive response yet, return nil
 */
@property (nonatomic, readonly) NSString *responseMIMEType;

/**
 *  Cache file path
 */
@property (nonatomic, readonly) NSString *cacheFilePath;

/**
 *  Finished file path
 */
@property (nonatomic, readonly) NSString *finishedFilePath;

/**
 *  Request URL string
 */
@property (nonatomic, readonly) NSString *requestURL;

/**
 *  Check if downloading
 */
@property (nonatomic, readonly) BOOL isDownloading;

/**
 *  Interval for each progress callback `downloadRequest:currentProgressUpdated:speed:received:totalReceived:expectedDataSize:`, default is 0.2.
 */
@property (nonatomic, assign) NSTimeInterval downloadProgressCallbackInterval;

/**
 *  Get average download speed in bytes/second.
 */
@property (nonatomic, readonly) double averageDownloadSpeed;

/**
 *  Check downloaded file content size
 */
@property (nonatomic, readonly) long long downloadedFileSize;

/**
 *  Check expected file size (from http response header)
 */
@property (nonatomic, readonly) long long expectedFileSize;

/**
 *  Set if this is a low priority request. Set this property before call `start` to take effect.
 *  Default value is `YES`.
 *  When set to `NO`, download will be started at default priority.
 */
@property (nonatomic, assign) BOOL isLowPriority;

/**
 *  Current retried times after download failed.
 *  If request not started or paused, call `start` will reset this property.
 */
@property (nonatomic, readonly) NSUInteger currentRetriedTimes;

/**
 *  Retry times for download failed due to response errors or network failed reasons.
 *  Default is 1.
 */
@property (nonatomic, assign) NSUInteger retryTimes;

/**
 *  The timeout interval for request.
 */
@property (nonatomic, assign) NSTimeInterval timeoutInterval;

/**
 *  If download failed, and current retried times < `retryTimes`, then retry after `retryAfterFailedDuration`
 *  Default is 0.5 second.
 */
@property (nonatomic, assign) NSTimeInterval retryAfterFailedDuration;

#pragma mark Callback blocks

//blocks callbacks work as same as delegate's methods

- (void)setSuccessedCallback:(void (^)(OTHTTPDownloadRequest *))successedCallback
              failedCallback:(void (^)(OTHTTPDownloadRequest *, NSError *))failedCallback
     writeFileFailedCallback:(void (^)(OTHTTPDownloadRequest *, NSException *))writeFileFailedCallback;

@property (nonatomic, copy) void(^receivedResponseCallback)(OTHTTPDownloadRequest *request);
@property (nonatomic, copy) void(^progressUpdatedCallback)(OTHTTPDownloadRequest *request,
                                                            float progress,
                                                            float bytesPerSecond,
                                                            unsigned long long totalReceived,
                                                            unsigned long long expectedDataSize);

#pragma mark Start/Pause

/**
 *  Begin or resume download. 
 *  After the request is started, a strong reference will be kept by the class object, so it won't dealloc until it pause or finished.
 */
- (void)start;

/**
 *  pause download
 */
- (void)pause;

#pragma mark HTTP header/cookie methods

/**
 *  set cookie. If you need to set cookie, you must do this before call start.
 *
 *  @param cookies The cookies to set.
 */
- (void)setCookies:(NSArray <NSHTTPCookie *> *)cookies;

/*!
 @method addValue:forHTTPHeaderField:
 @abstract Adds an HTTP header field in the current header
 dictionary.
 @discussion This method provides a way to add values to header
 fields incrementally. If a value was previously set for the given
 header field, the given value is appended to the previously-existing
 value. The appropriate field delimiter, a comma in the case of HTTP,
 is added by the implementation, and should not be added to the given
 value by the caller. Note that, in keeping with the HTTP RFC, HTTP
 header field names are case-insensitive.
 @param value the header field value.
 @param field the header field name (case-insensitive).
 */
- (void)addValue:(NSString *)value forHTTPHeaderField:(NSString *)field;

@end
