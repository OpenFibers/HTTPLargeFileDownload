//
//  OTHTTPRequest.h
//  OTHTTPRequestDemo
//
//  Created by openthread on 5/13/13.
//  Copyright (c) 2013 openthread. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OTHTTPRequest;

@protocol OTHTTPRequestDelegate <NSObject>

@optional

/**
 *  Request finished callback
 *
 *  @param request        The request instance
 */
- (void)otHTTPRequestFinished:(nonnull OTHTTPRequest *)request;

/**
 *  Request failed callback
 *
 *  @param request The request instance
 *  @param error   Callback Error
 */
- (void)otHTTPRequestFailed:(nonnull OTHTTPRequest *)request error:(nullable NSError *)error;

/**
 *  Request did receive response callback
 *
 *  @param request  The request instance
 *  @param response The received response
 */
- (void)otHTTPRequest:(nonnull OTHTTPRequest *)request didReceiveResponse:(nonnull NSURLResponse *)response;

/**
 *  Request received data callback
 *
 *  @param request           The request instance
 *  @param totalReceivedData Total received data
 */
- (void)otHTTPRequest:(nonnull OTHTTPRequest *)request receivedDataUpdated:(nonnull NSData *)totalReceivedData;

/**
 *  Upload progress updated callback, only for multipart/form-data (file uploading) request
 *
 *  @param request        The request instance
 *  @param uploadProgress Current upload progress
 *  @param bytesPerSecond Upload speed in bytes/second
 *  @param totalSent      Total sent bytes size
 *  @param contentLength  Post body content length
 */
- (void)otHTTPRequest:(nonnull OTHTTPRequest *)request
uploadProgressUpdated:(float)uploadProgress
                speed:(float)bytesPerSecond
            bytesSent:(unsigned long long)totalSent
        contentLength:(unsigned long long)contentLength;

@end

@interface OTHTTPRequest : NSObject

#pragma mark - Init Methods

/**
 *  Create request with an NSURL
 *
 *  @param URL The requesting URL
 *
 *  @return OTHTTPRequest instance
 */
- (nonnull instancetype)initWithURL:(nonnull NSURL *)URL;

/**
 *  URL of request;
 */
@property (nonatomic, readonly, nonnull) NSURL *URL;

/**
 *  Delegate of request
 */
@property (nonatomic, weak, nullable) id<OTHTTPRequestDelegate> delegate;

/**
 *  Custom user info
 */
@property (nonatomic, strong, nullable) id userInfo;

#pragma mark - Headers

/**
 *  set cookie. If you need to set cookie, you must do this before call start.
 *
 *  @param cookies The cookies to set.
 */
- (void)setCookies:(nonnull NSArray <NSHTTPCookie *> *)cookies;

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
- (void)addValue:(nonnull NSString *)value forHTTPHeaderField:(nonnull NSString *)field;

/**
 *  Get/set content encoding from current request header -> Content-Type -> charset.
 *  Return NSUTF8StringEncoding if request header -> Content-Type -> charset not setted.
 *  If want change this property, set it before calling start.
 */
@property (nonatomic, assign) NSStringEncoding contentTypeEncoding;

#pragma mark - Params

/**
 *  Get/set params for request
 */
@property (nonatomic, strong, nullable) NSDictionary<NSString */*key*/, NSString */*value*/> *getParams;

/**
 *  Add get params for request
 *
 *  @param params get params to add.
 */
- (void)addGetParams:(nonnull NSDictionary<NSString */*key*/, NSString */*value*/> *)getParams;

/**
 *  Get/set post params for request
 */
@property (nonatomic, strong, nullable) NSDictionary<NSString */*key*/, NSString */*value*/> *postParams;

/**
 *  Add post params for request
 *
 *  @param params post params to add
 */
- (void)addPostValue:(nonnull NSString *)value forKey:(nonnull NSString *)key;

/**
 *  Add file in post form with data
 *
 *  @param key      File key to post
 *  @param data     File data to post in multiform request
 *  @param fileName File name to post. If not specificed, will use the file path last component.
 *  @param MIMEType MIME type to post. If not specificed, will use extension of fileName.
 */
- (void)addFileForKey:(nonnull NSString *)key data:(nonnull NSData *)data fileName:(nullable NSString *)fileName MIMEType:(nullable NSString *)MIMEType;

/**
 *  Add file in post form with data
 *
 *  @param key      File key to post
 *  @param filePath File absolute path to post in multiform request
 *  @param fileName File name to post. If not specificed, will use the file path last component.
 *  @param MIMEType MIME type to post. If not specificed, will use extension of fileName.
 */
- (void)addFileForKey:(nonnull NSString *)key filePath:(nonnull NSString *)filePath fileName:(nullable NSString *)fileName MIMEType:(nullable NSString *)MIMEType;

#pragma mark - Options

/**
 *  Set if this is a low priority request. Set this property before call `start` to take effect.
 *  Default value is `YES`.
 *  When set to `NO`, request will be started at default priority.
 */
@property (nonatomic, assign) BOOL isLowPriority;

#pragma mark - Request and response

/**
 *  Get the response of request. Returns nil if response haven't reached yet.
 */
@property (nonatomic, readonly, nullable) NSURLResponse *response;

/**
 *  Get the response code of request. Returns 0 if http url response haven't reached yet.
 */
@property (nonatomic, readonly) NSInteger responseStatusCode;

/**
 *  Get responsed data
 *
 *  @return responsed data
 */
- (nullable NSData *)responseData;

/**
 *  Get responsed string using response's encoding. If response has no encoding info, use UTF8 encoding.
 *
 *  @return responsed string
 */
- (nullable NSString *)responseString;

#pragma mark - Start and cancel

/**
 *  begin request
 */
- (void)start;

/**
 *  cancel request
 */
- (void)cancel;

#pragma mark - Upload speed for multipart/form-data request

/**
 *  Get average upload speed in bytes/second.
 *  Only for multipart/form-data request (upload request). Otherwise returns 0.
 */
@property (nonatomic, readonly) double averageUploadSpeed;

/**
 *  Interval for each progress callback, default is 0.2.
 *  Only for multipart/form-data request (upload request).
 */
@property (nonatomic, assign) NSTimeInterval uploadCallbackInterval;

/**
 *  Uploaded content (http body) size.
 *  Only for multipart/form-data request (upload request).
 */
@property (nonatomic, readonly) unsigned long long uploadedContentSize;

/**
 *  HTTP content size
 */
@property (nonatomic, readonly) unsigned long long contentLength;

#pragma mark - Callback blocks

//blocks callbacks work as same as delegate's methods

@property (nonatomic, copy, nullable) void (^successedCallback)(OTHTTPRequest * _Nonnull request);
@property (nonatomic, copy, nullable) void (^failedCallback)(OTHTTPRequest * _Nonnull request,  NSError * _Nullable error);
@property (nonatomic, copy, nullable) void (^receivedResponseCallback)(OTHTTPRequest * _Nonnull request, NSURLResponse * _Nonnull response);
@property (nonatomic, copy, nullable) void (^receivedDataUpdatedCallback)(OTHTTPRequest * _Nonnull request, NSData * _Nonnull totalReceivedData);
@property (nonatomic, copy, nullable) void (^progressUpdatedCallback)(OTHTTPRequest * _Nonnull request,
                                                                      float progress,
                                                                      float bytesPerSecond,
                                                                      long long bytesSent,
                                                                      long long contentLength);
@end
