//
//  OTHTTPDownloadRequest.h
//  DownloadTest
//
//  Created by openthread on 12/17/12.
//  Copyright (c) 2012 openthread. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OTHTTPDownloadRequest;

@protocol OTHTTPDownloadRequestDelegate <NSObject>

@required

/*
 Download finished
 */
- (void)downloadRequestFinished:(OTHTTPDownloadRequest *)request;

/*
 Download failed
 */
- (void)downloadRequestFailed:(OTHTTPDownloadRequest *)request error:(NSError *)error;

/*
 Disk full
 */
- (void)downloadRequestWriteFileFailed:(OTHTTPDownloadRequest *)request;

@optional

/*
 Response received
 */
- (void)downloadRequestReceivedResponse:(OTHTTPDownloadRequest *)request;

/*
 Downloaded data
 */
- (void)downloadRequest:(OTHTTPDownloadRequest *)request
 currentProgressUpdated:(float)progress
               received:(NSUInteger)received
          totalReceived:(long long)totalReceived
       expectedDataSize:(long long)expectedDataSize;

@end

@interface OTHTTPDownloadRequest : NSObject

//Create download request with `urlString`, `cacheFileFullPath` and `finishedFileFullPath`
//Default timeout interval is 15 seconds
+ (OTHTTPDownloadRequest *)requestWithURL:(NSString *)urlString
                            cacheFilePath:(NSString *)cacheFileFullPath
                         finishedFilePath:(NSString *)finishedFileFullPath
                                 delegate:(id<OTHTTPDownloadRequestDelegate>)delegate;

//Create download request with `urlString`, `cacheFileFullPath`, `finishedFileFullPath` and `timeoutInterval`
+ (OTHTTPDownloadRequest *)requestWithURL:(NSString *)urlString
                            cacheFilePath:(NSString *)cacheFileFullPath
                         finishedFilePath:(NSString *)finishedFileFullPath
                          timeoutInterval:(NSTimeInterval)timeoutInterval
                                 delegate:(id<OTHTTPDownloadRequestDelegate>)delegate;

//Check response Status Code. If haven't receive response yet, return NSNotFound
@property (nonatomic,readonly) NSUInteger responseStatusCode;

//Check response MIME type. If haven't receive response yet, return nil
@property (nonatomic,readonly) NSString *responseMIMEType;

//Cache file path
@property (nonatomic,readonly) NSString *cacheFilePath;

//Finished file path
@property (nonatomic,readonly) NSString *finishedFilePath;

//Request URL
@property (nonatomic,readonly) NSString *requestURL;

//Check if download
@property (nonatomic,readonly) BOOL isDownloading;

//Check downloaded file size
@property (nonatomic,readonly) long long downloadedFileSize;

//Check expected file size
@property (nonatomic,readonly) long long expectedFileSize;

//Set if this is a low priority request. Set this property before call `start` to take effect.
//Default value is `YES`.
//When set to `NO`, download will be started at default priority.
@property (nonatomic,assign) BOOL isLowPriority;

//pause download
- (void)pause;

//begin or resume download
- (void)start;

//set cookie. If you need to set cookie, you must do this before call start.
- (void)setCookie:(NSArray *)cookie;

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
