//
//  OTHTTPRequest.m
//  OTHTTPRequestDemo
//
//  Created by openthread on 5/13/13.
//  Copyright (c) 2013 openthread. All rights reserved.
//

#import "OTHTTPRequest.h"
#import "OTHTTPRequestUtils.h"
#import "OTHTTPRequestPostObject.h"

@interface OTHTTPRequest () <NSURLConnectionDataDelegate>
@property (nonatomic, strong) NSMutableArray<OTHTTPRequestPostObject *> *postParamContainer;
@end

@implementation OTHTTPRequest
{
    NSMutableURLRequest *_request;
    NSURLResponse *_response;

    NSMutableData *_data;
    NSURLConnection *_connection;
}

#pragma mark - Init Methods

- (nonnull instancetype)initWithURL:(nonnull NSURL *)URL
{
    self = [super init];
    if (self)
    {
        _request = [NSMutableURLRequest requestWithURL:URL];
        self.isLowPriority = YES;
        self.shouldClearCachedResponseWhenRequestDone = YES;
        self.postParamContainer = [NSMutableArray array];
    }
    return self;
}

- (void)dealloc
{
    [self cancel];
}

#pragma mark - Header methods

- (void)addCookies:(nonnull NSArray <NSHTTPCookie *> *)cookies
{
    if ([cookies count] > 0)
    {
        NSHTTPCookie *cookie;
        NSString *cookieHeader = nil;
        for (cookie in cookies)
        {
            if (!cookieHeader)
            {
                cookieHeader = [NSString stringWithFormat:@"%@=%@", [cookie name], [cookie value]];
            }
            else
            {
                cookieHeader = [NSString stringWithFormat:@"%@; %@=%@", cookieHeader, [cookie name], [cookie value]];
            }
        }
        if (cookieHeader)
        {
            [_request setValue:cookieHeader forHTTPHeaderField:@"Cookie"];
        }
    }
}

- (void)setCookies:(nonnull NSArray <NSHTTPCookie *> *)cookies
{
    [self addCookies:cookies];
}

- (void)addValue:(nonnull NSString *)value forHTTPHeaderField:(nonnull NSString *)field
{
    [_request addValue:value forHTTPHeaderField:field];
}

- (NSStringEncoding)contentTypeEncoding
{
    NSString *contentType = [_request allHTTPHeaderFields][@"Content-Type"];
    NSString *encodingName = [OTHTTPRequestUtils encodingNameFromHTTPContentType:contentType];
    NSStringEncoding encoding = [OTHTTPRequestUtils NSStringEncodingFromEncodingName:encodingName];
    if (encoding == 0)
    {
        return NSUTF8StringEncoding;
    }
    return encoding;
}

- (void)setContentTypeEncoding:(NSStringEncoding)contentTypeEncoding
{
    NSString *encodingName = [OTHTTPRequestUtils encodingNameFromNSStringEncoding:contentTypeEncoding];
    NSString *contentType = [OTHTTPRequestUtils HTTPContentTypeForEncodingName:encodingName];
    if (contentType.length)
    {
        [_request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    }
}

#pragma mark - Param methods

#pragma mark Get params

- (nullable NSDictionary<NSString */*key*/, NSString */*value*/> *)getParams
{
    NSString *queryString = _request.URL.query;
    NSDictionary *queryDictionary = [OTHTTPRequestUtils parseGetParamsFromQueryString:queryString];
    return queryDictionary;
}

- (void)setGetParams:(nullable NSDictionary<NSString *,NSString *> *)getParams
{
    NSURLComponents *mutableURL = [NSURLComponents componentsWithString:_request.URL.absoluteString];
    NSString *paramString = [OTHTTPRequestUtils paramsStringFromParamDictionary:getParams];
    mutableURL.query = paramString;
    NSURL *newURL = mutableURL.URL;
    _request.URL = newURL;
}

- (void)addGetParams:(NSDictionary<NSString *,NSString *> *)getParams
{
    NSURLComponents *mutableURL = [NSURLComponents componentsWithString:_request.URL.absoluteString];
    NSString *paramString = [OTHTTPRequestUtils paramsStringFromParamDictionary:getParams];
    NSString *oldQuery = mutableURL.query;
    if (oldQuery)
    {
        if ([oldQuery hasSuffix:@"&"])
        {
            paramString = [oldQuery stringByAppendingString:paramString];
        }
        else
        {
            paramString = [oldQuery stringByAppendingFormat:@"&%@", paramString];
        }
    }
    mutableURL.query = paramString;
    NSURL *newURL = mutableURL.URL;
    _request.URL = newURL;
}

#pragma mark Post params

- (nullable NSDictionary<NSString *,NSString *> *)postParams
{
    if (self.postParamContainer.count == 0)
    {
        return nil;
    }
    NSMutableDictionary *postParams = [NSMutableDictionary dictionary];
    for (OTHTTPRequestPostObject *object in self.postParamContainer)
    {
        if (!object.isUploadObject)
        {
            postParams[object.key] = object.value;
        }
    }
    return [NSDictionary dictionaryWithDictionary:postParams];
}

- (void)setPostParams:(nullable NSDictionary<NSString *,NSString *> *)postParams
{
    [self.postParamContainer removeAllObjects];
    for (NSString *key in postParams.allKeys)
    {
        NSString *value = postParams[key];
        if ([key isKindOfClass:[NSString class]] && [value isKindOfClass:[NSString class]])
        {
            [self addPostValue:value forKey:key];
        }
    }
}

- (void)addPostValue:(nonnull NSString *)value forKey:(nonnull NSString *)key
{
    OTHTTPRequestPostObject *object = [[OTHTTPRequestPostObject alloc] init];
    object.key = key;
    object.value = value;
    [self.postParamContainer addObject:object];
}

- (void)addFileForKey:(nonnull NSString *)key data:(nonnull NSData *)data fileName:(nullable NSString *)fileName MIMEType:(nullable NSString *)MIMEType
{
    OTHTTPRequestPostObject *object = [[OTHTTPRequestPostObject alloc] init];
    object.key = key;
    object.fileData = data;
    object.fileName = fileName;
    object.MIMEType = MIMEType;
    [self.postParamContainer addObject:object];
}

- (void)addFileForKey:(nonnull NSString *)key filePath:(nonnull NSString *)filePath fileName:(nullable NSString *)fileName MIMEType:(nullable NSString *)MIMEType
{
    OTHTTPRequestPostObject *object = [[OTHTTPRequestPostObject alloc] init];
    object.key = key;
    object.filePath = filePath;
    object.fileName = fileName;
    object.MIMEType = MIMEType;
    [self.postParamContainer addObject:object];
}

#pragma mark - Request and response

- (nonnull NSURL *)URL
{
    return _request.URL;
}

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

- (nullable NSData *)responseData
{
    if (_data == nil)
    {
        return nil;
    }
    NSData *returnData = [NSData dataWithData:_data];
    return returnData;
}

- (nullable NSString *)responseString
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
