//
//  OTHTTPRequest.m
//  OTHTTPRequestDemo
//
//  Created by openthread on 5/13/13.
//  Copyright (c) 2013 openthread. All rights reserved.
//

#import "OTHTTPRequest.h"
#import "OTHTTPRequestUtils.h"

@interface OTHTTPRequest () <NSURLConnectionDataDelegate>
@end

@implementation OTHTTPRequest
{
    NSMutableURLRequest *_request;
    NSURLResponse *_response;

    NSMutableData *_data;
    NSURLConnection *_connection;
}

#pragma mark - Init Methods

- (instancetype)initWithURL:(NSURL *)URL
{
    self = [super init];
    if (self)
    {
        _request = [NSMutableURLRequest requestWithURL:URL];
        self.isLowPriority = YES;
        self.shouldClearCachedResponseWhenRequestDone = YES;
    }
    return self;
}

- (void)dealloc
{
    [self cancel];
}

#pragma mark - Param methods

- (void)setGetParams:(NSDictionary *)getParams
{
    
}

- (void)setPostParams:(NSDictionary *)postParams
{
    
}

- (void)addFileWithData:(NSData *)data fileName:(NSString *)fileName MIMEType:(NSString *)MIMEType
{
    
}

- (void)addFileWithFilePath:(NSString *)filePath fileName:(NSString *)fileName MIMEType:(NSString *)MIMEType
{
    
}

#pragma mark - Request and response

- (NSURLRequest *)request
{
    return _request;
}

- (NSURLResponse *)response
{
    return _response;
}

- (NSInteger)responseStatusCode
{
    if ([_response isKindOfClass:[NSHTTPURLResponse class]])
    {
        return [(NSHTTPURLResponse *)_response statusCode];
    }
    return 0;
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

- (NSString *)responseString
{
    NSString *responseEncoding = [self.response textEncodingName];
    NSData *responseData = [self responseData];
    NSString *responseString = nil;
    if (responseEncoding)
    {
        responseString = [[NSString alloc] initWithData:responseData
                                               encoding:CFStringConvertEncodingToNSStringEncoding(CFStringConvertIANACharSetNameToEncoding((CFStringRef)responseEncoding))];
    }
    else
    {
        responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    }
    return responseString;
}

#pragma mark - Start and cancel

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

#pragma mark - NSURLConnectionDataDelegate Callbacks

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    _response = response;
    if ([self.delegate respondsToSelector:@selector(otHTTPRequest:didReceiveResponse:)])
    {
        [self.delegate otHTTPRequest:self didReceiveResponse:response];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_data appendData:data];
    if ([self.delegate respondsToSelector:@selector(otHTTPRequest:dataUpdated:)])
    {
        [self.delegate otHTTPRequest:self dataUpdated:data];
    }
    if ([self.delegate respondsToSelector:@selector(otHTTPRequest:dataUpdated:totalData:)])
    {
        NSData *callbackData = [NSData dataWithData:_data];
        [self.delegate otHTTPRequest:self dataUpdated:data totalData:callbackData];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if ([self.delegate respondsToSelector:@selector(otHTTPRequestFinished:)])
    {
        [self.delegate otHTTPRequestFinished:self];
    }
    if (self.shouldClearCachedResponseWhenRequestDone)
    {
        if (_request.URL)
        {
            [[NSURLCache sharedURLCache] removeCachedResponseForRequest:_request];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(otHTTPRequestFailed:error:)])
    {
        [self.delegate otHTTPRequestFailed:self error:error];
    }
    if (self.shouldClearCachedResponseWhenRequestDone)
    {
        if (_request.URL)
        {
            [[NSURLCache sharedURLCache] removeCachedResponseForRequest:_request];
        }
    }
    [self cancel];
}

@end
