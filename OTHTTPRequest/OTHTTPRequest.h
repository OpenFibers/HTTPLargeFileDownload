//
//  OTHTTPRequest.h
//  OTHTTPRequestDemo
//
//  Created by openthread on 5/13/13.
//  Copyright (c) 2013 openthread. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OTHTTPRequest;

@interface OTHTTPRequestUploadFile : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSString *contentType;
@property (nonatomic, strong) NSData *fileData;
@end

@interface NSMutableURLRequest (GetAndPostParams)

/**
 *  Setup simple request with get params.
 *
 *  @param getParams Get params to be set.
 */
- (void)setUpGetParams:(NSDictionary *)getParams;

/**
 *  Setup simple request with post params.
 *
 *  @param postParams Post params to be set.
 */
- (void)setUpPostParams:(NSDictionary *)postParams;

/**
 *  Multipart form data request with post params, and single file's data. Using NSUTF8StringEncoding.
 *
 *  @param postParams Post params to be set.
 *  @param file       File to be upload.
 */
- (void)setUpMultiPartFormDataRequestWithPostParams:(NSDictionary *)postParams file:(OTHTTPRequestUploadFile *)file;

/**
 *  Multipart form data request with post params, and files' data. Using NSUTF8StringEncoding.
 *
 *  @param postParams Post params to be set.
 *  @param filesArray Files to be upload.
 */
- (void)setUpMultiPartFormDataRequestWithPostParams:(NSDictionary *)postParams filesArray:(NSArray<OTHTTPRequestUploadFile *> *)filesArray;

/**
 *  Multipart form data request with post params, and files' data. Using specific string encoding.
 *
 *  @param postParams Post params to be set.
 *  @param filesArray Files to be upload.
 *  @param encoding   Encode for post.
 */
- (void)setUpMultiPartFormDataRequestWithPostParams:(NSDictionary *)postParams filesArray:(NSArray<OTHTTPRequestUploadFile *> *)filesArray encoding:(NSStringEncoding)encoding;

@end

@protocol OTHTTPRequestDelegate <NSObject>

@required
- (void)otHTTPRequestFinished:(OTHTTPRequest *)request;
- (void)otHTTPRequestFailed:(OTHTTPRequest *)request error:(NSError *)error;

@optional
- (void)otHTTPRequest:(OTHTTPRequest *)request didReceiveResponse:(NSURLResponse *)response;
- (void)otHTTPRequest:(OTHTTPRequest *)request dataUpdated:(NSData *)data;
- (void)otHTTPRequest:(OTHTTPRequest *)request dataUpdated:(NSData *)data totalData:(NSData *)totalData;

@end

@interface OTHTTPRequest : NSObject

#pragma mark - Init Methods

//Create request with a NSURLRequest.
- (id)initWithNSURLRequest:(NSURLRequest *)request;

@property (nonatomic, weak) id<OTHTTPRequestDelegate> delegate;
@property (nonatomic, strong) id userInfo;

#pragma mark - Options

//Set if this is a low priority request. Set this property before call `start` to take effect.
//Default value is `YES`.
//When set to `NO`, request will be started at default priority.
@property (nonatomic, assign) BOOL isLowPriority;

//To avoid memory issues, default is YES.
@property (nonatomic, assign) BOOL shouldClearCachedResponseWhenRequestDone;

#pragma mark - Request and response

@property (nonatomic, readonly) NSURLRequest *request;

//Returns nil if response haven't reached yet.
@property (nonatomic, readonly) NSURLResponse *response;

//Returns 0 if http url response haven't reached yet.
@property (nonatomic, readonly) NSInteger responseStatusCode;

//Get responsed data
- (NSData *)responseData;

//Get responsed string using response's encoding. If response has no encoding info, use UTF8 encoding.
- (NSString *)responseString;

#pragma mark - Start and cancel

//cancel request
- (void)cancel;

//begin request
- (void)start;

@end
