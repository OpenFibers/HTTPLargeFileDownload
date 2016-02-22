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
- (void)otHTTPRequestFinished:(nonnull OTHTTPRequest *)request;
- (void)otHTTPRequestFailed:(nonnull OTHTTPRequest *)request error:(nullable NSError *)error;
- (void)otHTTPRequest:(nonnull OTHTTPRequest *)request didReceiveResponse:(nonnull NSURLResponse *)response;
- (void)otHTTPRequest:(nonnull OTHTTPRequest *)request dataUpdated:(nonnull NSData *)data;
- (void)otHTTPRequest:(nonnull OTHTTPRequest *)request dataUpdated:(nonnull NSData *)data totalData:(nonnull NSData *)totalData;

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
 *  @param key      file key to post
 *  @param data     file data to add
 *  @param fileName file name to post
 *  @param MIMEType MIME type to post
 */
- (void)addFileForKey:(nonnull NSString *)key data:(nonnull NSData *)data fileName:(nullable NSString *)fileName MIMEType:(nullable NSString *)MIMEType;

/**
 *  Add file in post form with data
 *
 *  @param key      file key to post
 *  @param filePath file path to add
 *  @param fileName file name to post
 *  @param MIMEType MIME type to post
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

@end
