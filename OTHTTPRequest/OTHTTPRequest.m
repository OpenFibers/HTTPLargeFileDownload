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
#import "OTMultipartFormRequestInputStream.h"
#import "OTLivingRequestContainer.h"

@interface OTHTTPRequest () <NSURLConnectionDataDelegate, OTMultipartFormRequestInputStreamProgressDelegate>
@property (nonatomic, strong) NSMutableArray<OTHTTPRequestPostObject *> *postParamContainer;
@property (nonatomic, strong) NSString *multipartFormBoundary;
@property (nonatomic, strong) NSMutableURLRequest *request;
@property (nonatomic, assign) NSTimeInterval connectionBeginTime;
@property (nonatomic, assign) NSTimeInterval lastProgressCallbackTime;
@end

@implementation OTHTTPRequest
{
    NSURLResponse *_response;

    NSMutableData *_receivedData;
    NSURLConnection *_connection;
}

#pragma mark - Init Methods

- (nonnull instancetype)initWithURL:(nonnull NSURL *)URL
{
    self = [super init];
    if (self)
    {
        self.request = [NSMutableURLRequest requestWithURL:URL];
        self.isLowPriority = YES;
        self.postParamContainer = [NSMutableArray array];
        
        // We don't bother to check if post data contains the boundary, since it's pretty unlikely that it does.
        CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
        NSString *uuidString = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
        CFRelease(uuid);
        self.multipartFormBoundary = [NSString stringWithFormat:@"--OTHTTPRequest-%@", uuidString];
        
        self.uploadCallbackInterval = 0.2;
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
            [self.request setValue:cookieHeader forHTTPHeaderField:@"Cookie"];
        }
    }
}

- (void)setCookies:(nonnull NSArray <NSHTTPCookie *> *)cookies
{
    [self addCookies:cookies];
}

- (void)addValue:(nonnull NSString *)value forHTTPHeaderField:(nonnull NSString *)field
{
    [self.request addValue:value forHTTPHeaderField:field];
}

- (NSStringEncoding)contentTypeEncoding
{
    NSString *contentType = [self.request allHTTPHeaderFields][@"Content-Type"];
    NSString *encodingName = [OTHTTPRequestUtils encodingNameFromHTTPContentType:contentType];
    NSStringEncoding encoding = [OTHTTPRequestUtils NSStringEncodingFromEncodingName:encodingName];
    if (encoding == 0 ||
        encoding == 0xffffffff/*apple returns a 4 bytes -1 on 16 bits CPU, not 8 bytes*/ ||
        encoding == NSNotFound)
    {
        return NSUTF8StringEncoding;
    }
    return encoding;
}

- (void)setContentTypeEncoding:(NSStringEncoding)contentTypeEncoding
{
    [self updateContentTypeWithEncoding:contentTypeEncoding];
}

- (void)updateContentTypeWithEncoding:(NSStringEncoding)contentTypeEncoding
{
    NSString *encodingName = [OTHTTPRequestUtils encodingNameFromNSStringEncoding:contentTypeEncoding];
    NSString *contentType = nil;
    if ([self isGetRequest])
    {
        contentType = nil;//remove content type
    }
    else if ([self isMultipartFormRequest])
    {
        contentType = [OTHTTPRequestUtils HTTPMultipartContentTypeForEncodingName:encodingName boundary:self.multipartFormBoundary];
    }
    else
    {
        contentType = [OTHTTPRequestUtils HTTPWWWFormTypeForEncodingName:encodingName];
    }
    [self.request setValue:contentType forHTTPHeaderField:@"Content-Type"];
}

- (BOOL)isGetRequest
{
    return self.postParamContainer.count == 0;
}

- (BOOL)isMultipartFormRequest
{
    for (OTHTTPRequestPostObject *object in self.postParamContainer)
    {
        if (object.fileData || object.filePath)
        {
            return YES;
        }
    }
    return NO;
}

#pragma mark - Param methods

#pragma mark Get params

- (nullable NSDictionary<NSString */*key*/, NSString */*value*/> *)getParams
{
    NSString *queryString = self.request.URL.query;
    NSDictionary *queryDictionary = [OTHTTPRequestUtils parseGetParamsFromQueryString:queryString];
    return queryDictionary;
}

- (void)setGetParams:(nullable NSDictionary<NSString *,NSString *> *)getParams
{
    NSURLComponents *mutableURL = [NSURLComponents componentsWithString:self.request.URL.absoluteString];
    NSString *paramString = [OTHTTPRequestUtils paramsStringFromParamDictionary:getParams];
    mutableURL.percentEncodedQuery = paramString;
    NSURL *newURL = mutableURL.URL;
    self.request.URL = newURL;
}

- (void)addGetParams:(NSDictionary<NSString *,NSString *> *)getParams
{
    NSURLComponents *mutableURL = [NSURLComponents componentsWithString:self.request.URL.absoluteString];
    NSString *paramString = [OTHTTPRequestUtils paramsStringFromParamDictionary:getParams];
    NSString *oldQuery = mutableURL.percentEncodedQuery;
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
    mutableURL.percentEncodedQuery = paramString;
    NSURL *newURL = mutableURL.URL;
    self.request.URL = newURL;
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
    
    if (postParams.allKeys.count)
    {
        [self updateContentTypeWithEncoding:self.contentTypeEncoding];
    }
    else
    {
        for (NSString *key in postParams.allKeys)
        {
            NSString *value = postParams[key];
            if ([key isKindOfClass:[NSString class]] && [value isKindOfClass:[NSString class]])
            {
                [self addPostValue:value forKey:key];
            }
        }
    }
}

- (void)addPostValue:(nonnull NSString *)value forKey:(nonnull NSString *)key
{
    OTHTTPRequestPostObject *object = [[OTHTTPRequestPostObject alloc] init];
    object.key = key;
    object.value = value;
    [self.postParamContainer addObject:object];
    [self updateContentTypeWithEncoding:self.contentTypeEncoding];
}

- (void)addFileForKey:(nonnull NSString *)key data:(nonnull NSData *)data fileName:(nullable NSString *)fileName MIMEType:(nullable NSString *)MIMEType
{
    OTHTTPRequestPostObject *object = [[OTHTTPRequestPostObject alloc] init];
    object.key = key;
    object.fileData = data;
    object.fileName = fileName;
    object.MIMEType = MIMEType;
    [self.postParamContainer addObject:object];
    [self updateContentTypeWithEncoding:self.contentTypeEncoding];
}

- (void)addFileForKey:(nonnull NSString *)key filePath:(nonnull NSString *)filePath fileName:(nullable NSString *)fileName MIMEType:(nullable NSString *)MIMEType
{
    OTHTTPRequestPostObject *object = [[OTHTTPRequestPostObject alloc] init];
    object.key = key;
    object.filePath = filePath;
    object.fileName = fileName;
    object.MIMEType = MIMEType;
    [self.postParamContainer addObject:object];
    [self updateContentTypeWithEncoding:self.contentTypeEncoding];
}

- (void)setHTTPBody:(nonnull NSData *)HTTPBody
{
    [self.request setHTTPBody:HTTPBody];
}

- (void)setHTTPBodyUseCurrentEncodeSettingWithBodyString:(nonnull NSString *)HTTPBodyString
{
    NSData *data = [HTTPBodyString dataUsingEncoding:self.contentTypeEncoding];
    [self setHTTPBody:data];
}

#pragma mark - Build HTTP Body

- (void)buildHTTPBody
{
    if ([self isGetRequest] && self.request.HTTPBody.length == 0)
    {
        [self.request setHTTPMethod:@"GET"];
    }
    else
    {
        [self.request setHTTPMethod:@"POST"];
        
        if (self.request.HTTPBody.length != 0)//if HTTP body was set manually, only update content length
        {
            NSData *postData = [self.request HTTPBody];
            NSString *postLength = [NSString stringWithFormat:@"%tu", [postData length]];
            [self.request setValue:postLength forHTTPHeaderField:@"Content-Length"];
            _requestBodyContentLength = [postData length];
        }
        else if ([self isMultipartFormRequest])
        {
            OTMultipartFormRequestInputStream *stream = [[OTMultipartFormRequestInputStream alloc] initWithEncoding:self.contentTypeEncoding];
            stream.progressDelegate = self;
            [stream setupHTTPBodyWithObjects:self.postParamContainer boundary:self.multipartFormBoundary];
            [self.request setHTTPBodyStream:stream];
            
            NSString *postLength = [NSString stringWithFormat:@"%tu", stream.contentLength];
            [self.request setValue:postLength forHTTPHeaderField:@"Content-Length"];
            _requestBodyContentLength = stream.contentLength;
        }
        else
        {
            NSString *paramString = [OTHTTPRequestUtils paramsStringFromParamDictionary:self.postParams encoding:self.contentTypeEncoding];
            NSData *postData = [paramString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
            [self.request setHTTPBody:postData];
            
            NSString *postLength = [NSString stringWithFormat:@"%tu", [postData length]];
            [self.request setValue:postLength forHTTPHeaderField:@"Content-Length"];
            _requestBodyContentLength = [postData length];
        }
    }
}


#pragma mark - Request and response

- (nonnull NSURL *)URL
{
    return self.request.URL;
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
    if (_receivedData == nil)
    {
        return nil;
    }
    NSData *returnData = [NSData dataWithData:_receivedData];
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
    _receivedData = nil;
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
    self.connectionBeginTime = [[NSDate date] timeIntervalSince1970];

    _receivedData = [NSMutableData data];
    [self buildHTTPBody];
    
    _connection = [[NSURLConnection alloc] initWithRequest:self.request delegate:self startImmediately:NO];
    if (!self.isLowPriority)
    {
        [_connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
    [_connection start];
    [[OTLivingRequestContainer sharedContainer] addRequest:self];
}

#pragma mark - Stream upload progress callback

- (void)otMultipartFormRequestInputStreamReadProgressUpdated:(nonnull OTMultipartFormRequestInputStream *)stream
                                                bytesHasRead:(unsigned long long)bytesHasRead
                                                  totalBytes:(unsigned long long)totalBytes
{
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval elapsed = currentTime - _connectionBeginTime;
    _averageUploadSpeed = (elapsed == 0 ? 0 : bytesHasRead / elapsed);
    if (currentTime - self.lastProgressCallbackTime > self.uploadCallbackInterval)
    {
        self.lastProgressCallbackTime = currentTime;
        double progress = 0.0f;
        if (totalBytes != 0)
        {
            progress = (double)(bytesHasRead / (double)totalBytes);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(otHTTPRequest:uploadProgressUpdated:speed:bytesSent:contentLength:)])
            {
                [self.delegate otHTTPRequest:self
                       uploadProgressUpdated:progress
                                       speed:self.averageUploadSpeed
                                   bytesSent:bytesHasRead
                               contentLength:totalBytes];
            }
            if (self.uploadProgressCallback)
            {
                self.uploadProgressCallback(self, progress, self.averageUploadSpeed, bytesHasRead, totalBytes);
            }
        });
    }
}

#pragma mark - NSURLConnectionDataDelegate Callbacks

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    _response = response;
    if ([self.delegate respondsToSelector:@selector(otHTTPRequest:didReceiveResponse:)])
    {
        [self.delegate otHTTPRequest:self didReceiveResponse:response];
    }
    if (self.receivedResponseCallback)
    {
        self.receivedResponseCallback(self, response);
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_receivedData appendData:data];
    
    if ([self.delegate respondsToSelector:@selector(otHTTPRequest:receivedDataUpdated:)] ||
        self.receivedDataUpdatedCallback)
    {
        NSData *callbackData = [NSData dataWithData:_receivedData];
        if ([self.delegate respondsToSelector:@selector(otHTTPRequest:receivedDataUpdated:)])
        {
            [self.delegate otHTTPRequest:self receivedDataUpdated:callbackData];
        }
        if (self.receivedDataUpdatedCallback)
        {
            self.receivedDataUpdatedCallback(self, callbackData);
        }
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if ([self.delegate respondsToSelector:@selector(otHTTPRequestFinished:)])
    {
        [self.delegate otHTTPRequestFinished:self];
    }
    
    if (self.successedCallback)
    {
        self.successedCallback(self);
    }
    
    //self may dealloc after remove from container, so don't execute any code below this line
    [[OTLivingRequestContainer sharedContainer] removeRequest:self];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(otHTTPRequestFailed:error:)])
    {
        [self.delegate otHTTPRequestFailed:self error:error];
    }
    
    if (self.failedCallback)
    {
        self.failedCallback(self, error);
    }
    
    [self cancel];

    //self may dealloc after remove from container, so don't execute any code below this line
    [[OTLivingRequestContainer sharedContainer] removeRequest:self];
}

@end
