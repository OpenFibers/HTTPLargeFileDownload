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

- (void)otRequestFinished:(OTHTTPRequest *)request;
- (void)otRequestFailed:(OTHTTPRequest *)request;

@end

@interface OTHTTPRequest : NSObject

//Create request with a NSURLRequest.
- (id)initWithNSURLRequest:(NSURLRequest *)request;

@property (nonatomic, assign) id<OTHTTPRequestDelegate> delegate;

@property (nonatomic,readonly) NSURLRequest *request;

//If haven't receive response yet, return nil.
@property (nonatomic,readonly) NSURLResponse *response;

//Set if this is a low priority request. Set this property before call `start` to take effect.
//Default value is `YES`.
//When set to `NO`, request will be started at default priority.
@property (nonatomic,assign) BOOL isLowPriority;

//cancel request
- (void)cancel;

//begin request
- (void)start;

//Get responsed data
- (NSData *)responseData;

@end
