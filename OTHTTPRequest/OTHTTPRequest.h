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
- (void)otHTTPRequestFinished:(OTHTTPRequest *)request;
- (void)otHTTPRequestFailed:(OTHTTPRequest *)request error:(NSError *)error;
- (void)otHTTPRequest:(OTHTTPRequest *)request didReceiveResponse:(NSURLResponse *)response;
- (void)otHTTPRequest:(OTHTTPRequest *)request dataUpdated:(NSData *)data;
- (void)otHTTPRequest:(OTHTTPRequest *)request dataUpdated:(NSData *)data totalData:(NSData *)totalData;

@end

@interface OTHTTPRequest : NSObject

#pragma mark - Init Methods

/**
 *  Create request with a NSURL
 *
 *  @param URL The requesting URL
 *
 *  @return OTHTTPRequest instance
 */
- (instancetype)initWithURL:(NSURL *)URL;

/**
 *  URL of request;
 */
@property (nonatomic, readonly) NSURL *URL;

/**
 *  Delegate of request
 */
@property (nonatomic, weak) id<OTHTTPRequestDelegate> delegate;

/**
 *  Custom user info
 */
@property (nonatomic, strong) id userInfo;

#pragma mark - Params

/**
 *  Get/set params for request
 */
@property (nonatomic, strong) NSDictionary<NSString */*key*/, NSString */*value*/> *getParams;

/**
 *  Add get params for request
 *
 *  @param params get params to add.
 */
- (void)addGetParams:(NSDictionary<NSString */*key*/, NSString */*value*/> *)params;

/**
 *  Get/set post params for request
 */
@property (nonatomic, strong) NSDictionary<NSString */*key*/, NSString */*value*/> *postParams;

/**
 *  Add post params for request
 *
 *  @param params post params to add
 */
- (void)addPostParams:(NSDictionary<NSString */*key*/, NSString */*value*/> *)params;

/**
 *  Add file in post form with data
 *
 *  @param data     file data to add
 *  @param fileName file name to post
 *  @param MIMEType MIME type to post
 */
- (void)addFileWithData:(NSData *)data fileName:(NSString *)fileName MIMEType:(NSString *)MIMEType;

/**
 *  Add file in post form with data
 *
 *  @param filePath file path to add
 *  @param fileName file name to post
 *  @param MIMEType MIME type to post
 */
- (void)addFileWithFilePath:(NSString *)filePath fileName:(NSString *)fileName MIMEType:(NSString *)MIMEType;

#pragma mark - Options

/**
 *  Set if this is a low priority request. Set this property before call `start` to take effect.
 *  Default value is `YES`.
 *  When set to `NO`, request will be started at default priority.
 */
@property (nonatomic, assign) BOOL isLowPriority;

/**
 *  If set to YES, when request done, cached response will be cleared. 
 *  To avoid memory issues, default is YES.
 */
@property (nonatomic, assign) BOOL shouldClearCachedResponseWhenRequestDone;

#pragma mark - Request and response

/**
 *  Get the response of request. Returns nil if response haven't reached yet.
 */
@property (nonatomic, readonly) NSURLResponse *response;

/**
 *  Get the response code of request. Returns 0 if http url response haven't reached yet.
 */
@property (nonatomic, readonly) NSInteger responseStatusCode;

/**
 *  Get responsed data
 *
 *  @return responsed data
 */
- (NSData *)responseData;

/**
 *  Get responsed string using response's encoding. If response has no encoding info, use UTF8 encoding.
 *
 *  @return responsed string
 */
- (NSString *)responseString;

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
