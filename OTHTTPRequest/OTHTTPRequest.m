//
//  OTHTTPRequest.m
//  OTHTTPRequestDemo
//
//  Created by openthread on 5/13/13.
//  Copyright (c) 2013 openthread. All rights reserved.
//

#import "OTHTTPRequest.h"

@interface OTHTTPRequest()<NSURLConnectionDataDelegate>
@end

@implementation OTHTTPRequest
{
    NSURLRequest *_request;
    NSURLResponse *_response;
    
    NSMutableData *_data;
    NSURLConnection *_connection;
}

//Create request with a NSURLRequest.
- (id)initWithNSURLRequest:(NSURLRequest *)request
{
    self = [super init];
    if (self)
    {
        _request = request;
    }
    return self;
}

- (void)dealloc
{
    [self cancel];
}

- (NSURLRequest *)request
{
    return _request;
}

- (NSURLResponse *)response
{
    return _response;
}

- (void)cancel
{
    [_connection cancel];
    _connection = nil;
    _data = nil;
    _response = nil;
}

- (void)start
{
    if (![NSThread isMainThread])
    {
        [self performSelectorOnMainThread:@selector(start) withObject:nil waitUntilDone:NO];
        return;
    }
    
    if (!_connection)
    {
        [self beginConnection];
    }
}

- (void)beginConnection
{
    _data = [NSMutableData data];
    _connection = [[NSURLConnection alloc] initWithRequest:_request delegate:self startImmediately:NO];
    if (!self.isLowPriority)
    {
        [_connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
    [_connection start];
}

- (NSData *)responseData
{
    if (_data == nil)
    {
        return nil;
    }
    NSData *returnData = [NSData dataWithData:_data];
    return returnData;
}

#pragma mark - NSURLConnectionDataDelegate Callbacks

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    _response = response;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if ([self.delegate respondsToSelector:@selector(otRequestFinished:)])
    {
        [self.delegate otRequestFinished:self];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(otRequestFailed:)])
    {
        [self.delegate otRequestFailed:self];
    }
    [self cancel];
}

@end
