//
//  OTHTTPDownloadRequest.m
//  DownloadTest
//
//  Created by openthread on 12/17/12.
//  Copyright (c) 2012 openthread. All rights reserved.
//

#import "OTHTTPDownloadRequest.h"

#if !__has_feature(objc_arc)
#error ARC is required
#endif

@interface OTHTTPDownloadRequest ()
@property (nonatomic, retain) NSURLConnection *connection;
@end

@implementation OTHTTPDownloadRequest
{
    NSMutableURLRequest *_request;
    NSFileHandle *_cacheFileHandle;
    
    id<OTHTTPDownloadRequestDelegate> _delegate;
    
    NSString *_urlString;//download URL
    NSString *_cacheFilePath;//cache file path
    NSString *_finishedFilePath;//finished file path
    
    NSUInteger _responseStatusCode;//HTTP Status Code
    NSString *_responseMIMEType;
    long long _currentContentLength;//current downloaded bytes count
    long long _expectedContentLength;//expected file length
}
@synthesize connection = _connection;

- (NSUInteger)responseStatusCode
{
    return _responseStatusCode;
}

- (NSString *)responseMIMEType
{
    return _responseMIMEType;
}

- (NSString *)cacheFilePath
{
    return _cacheFilePath;
}

- (NSString *)finishedFilePath
{
    return _finishedFilePath;
}

- (BOOL)writeToFile:(NSData *)data
{
    BOOL writeSuccessed = YES;
    NSFileHandle *writeFileHandle = _cacheFileHandle;
    if (writeFileHandle != nil)
    {
        @try
        {
            [writeFileHandle writeData:data];
        }
        @catch (NSException *exception)
        {
            writeSuccessed = NO;
            if ([_delegate respondsToSelector:@selector(downloadRequestWriteFileFailed:)])
            {
                [_delegate downloadRequestWriteFileFailed:self];
            }
        }
    }
    else
    {
        writeSuccessed = NO;
    }
    if (!writeSuccessed)
    {
        [self pause];
    }
    return writeSuccessed;
}

+ (void)createFileAtPath:(NSString *)fileFullPath
{
    if([[NSFileManager defaultManager] fileExistsAtPath:fileFullPath] == NO)
    {
        [[NSFileManager defaultManager] createFileAtPath:fileFullPath contents:nil attributes:nil];
    }
}

+ (long long)fileSizeAtPath:(NSString*)fileFullPath
{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:fileFullPath])
    {
        return [[manager attributesOfItemAtPath:fileFullPath error:nil] fileSize];
    }
    return 0;
}

- (id)initWithURL:(NSString *)urlString
        cacheFile:(NSString *)cacheFile
 finishedFilePath:(NSString *)finishedFilePath
         delegate:(id<OTHTTPDownloadRequestDelegate>)delegate;
{
    self = [self initWithURL:urlString
                   cacheFile:cacheFile
            finishedFilePath:finishedFilePath
             timeoutInterval:15
//             timeoutInterval:0.1
                    delegate:delegate];
    if (self)
    {
        //
    }
    return self;
}

- (id)initWithURL:(NSString *)urlString
        cacheFile:(NSString *)cacheFile
 finishedFilePath:(NSString *)finishedFilePath
  timeoutInterval:(NSTimeInterval)timeoutInterval
         delegate:(id<OTHTTPDownloadRequestDelegate>)delegate;
{
    self = [super init];
    if (self)
    {
        //Set cache file path and finished file path
        _urlString = urlString;
        _cacheFilePath = cacheFile;
        _finishedFilePath = finishedFilePath;
        
        NSURL *url= [NSURL URLWithString:_urlString];
        _request = [[NSMutableURLRequest alloc] initWithURL:url
                                                cachePolicy:NSURLRequestReloadIgnoringCacheData
                                            timeoutInterval:timeoutInterval];
        
        //Set delegate
        _delegate = delegate;
        
        self.isLowPriority = YES;
    }
    return self;
}

- (void)closeConnection
{
    if (self.connection)
    {
        [self.connection cancel];
        self.connection = nil;
        _responseStatusCode = NSNotFound;
        _responseMIMEType = nil;
    }
    if (_cacheFileHandle)
    {
        [_cacheFileHandle closeFile];
        _cacheFileHandle = nil;
    }
}

- (void)beginConnection
{
    [OTHTTPDownloadRequest createFileAtPath:_cacheFilePath];
    _cacheFileHandle = [NSFileHandle fileHandleForUpdatingAtPath:_cacheFilePath];
    if (_cacheFileHandle)
    {
        [_cacheFileHandle seekToEndOfFile];
        
        _responseStatusCode = NSNotFound;
        
        //get last download data size
        long long dataSize = [OTHTTPDownloadRequest fileSizeAtPath:_cacheFilePath];
        _currentContentLength = dataSize;
        
        //set request range
        NSString *rangeString = [NSString stringWithFormat:@"bytes=%lld-", dataSize];
        [_request setValue:rangeString forHTTPHeaderField:@"Range"];
        
        //Setup connection
        self.connection = [[NSURLConnection alloc] initWithRequest:_request delegate:self startImmediately:NO];
        if (!self.isLowPriority)
        {
            [self.connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        }
        [self.connection start];
    }
    else
    {
        if ([_delegate respondsToSelector:@selector(downloadRequestWriteFileFailed:)])
        {
            [_delegate downloadRequestWriteFileFailed:self];
        }
    }
}

- (void)addCookies:(NSArray *)cookies
{
    if ([cookies count] > 0)
    {
		NSHTTPCookie *cookie;
		NSString *cookieHeader = nil;
		for (cookie in cookies)
        {
			if (!cookieHeader)
            {
				cookieHeader = [NSString stringWithFormat: @"%@=%@",[cookie name],[cookie value]];
			}
            else
            {
				cookieHeader = [NSString stringWithFormat: @"%@; %@=%@",cookieHeader,[cookie name],[cookie value]];
			}
		}
		if (cookieHeader)
        {
            [_request setValue:cookieHeader forHTTPHeaderField:@"Cookie"];
		}
	}
}

- (void)pause
{
    [self closeConnection];
}

- (void)start
{
    if (!self.connection)
    {
        [self beginConnection];
    }
}

- (void)setCookie:(NSArray *)cookie
{
    [self addCookies:cookie];
}

- (void)addValue:(NSString *)value forHTTPHeaderField:(NSString *)field
{
    [_request addValue:value forHTTPHeaderField:field];
}

- (BOOL)isDownloading
{
    return self.connection != nil;
}

- (NSString *)requestURL
{
    return _urlString;
}

- (long long)downloadedFileSize
{
    return _currentContentLength;
}

- (long long)expectedFileSize
{
    return _expectedContentLength;
}

+ (OTHTTPDownloadRequest *)requestWithURL:(NSString *)urlString
                            cacheFilePath:(NSString *)cacheFileFullPath
                         finishedFilePath:(NSString *)finishedFileFullPath
                                 delegate:(id<OTHTTPDownloadRequestDelegate>)delegate;
{
    OTHTTPDownloadRequest *request = [[OTHTTPDownloadRequest alloc] initWithURL:urlString
                                                                      cacheFile:cacheFileFullPath
                                                               finishedFilePath:finishedFileFullPath
                                                                       delegate:delegate];
    return request;
}

+ (OTHTTPDownloadRequest *)requestWithURL:(NSString *)urlString
                            cacheFilePath:(NSString *)cacheFileFullPath
                         finishedFilePath:(NSString *)finishedFileFullPath
                          timeoutInterval:(NSTimeInterval)timeoutInterval
                                 delegate:(id<OTHTTPDownloadRequestDelegate>)delegate;
{
    OTHTTPDownloadRequest *request = [[OTHTTPDownloadRequest alloc] initWithURL:urlString
                                                                      cacheFile:cacheFileFullPath
                                                               finishedFilePath:finishedFileFullPath
                                                                timeoutInterval:timeoutInterval
                                                                       delegate:delegate];
    return request;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    _responseStatusCode = [(NSHTTPURLResponse *)response statusCode];//status code为406可能是range超范围了
    _responseMIMEType = [(NSHTTPURLResponse *)response MIMEType];
    if(200 == _responseStatusCode)//request uncached file
    {
        long long expectedLengthInCurrentRequest = [response expectedContentLength];
        _expectedContentLength = expectedLengthInCurrentRequest;
    }
    else if(206 == _responseStatusCode)//resume broken file downloading
    {
        long long expectedLengthInCurrentRequest = [response expectedContentLength];
        _expectedContentLength = _currentContentLength + expectedLengthInCurrentRequest;
    }
    if ([_delegate respondsToSelector:@selector(downloadRequestReceivedResponse:)])
    {
        [_delegate downloadRequestReceivedResponse:self];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (200 == _responseStatusCode || 206 == _responseStatusCode)
    {
        if (![self writeToFile:data])
        {
            return;
        }
        NSUInteger dataLength = [data length];
        _currentContentLength += dataLength;
        if ([_delegate respondsToSelector:@selector(downloadRequest:currentProgressUpdated:received:totalReceived:expectedDataSize:)])
        {
            CGFloat progress = 0.0f;
            if (_expectedContentLength != 0)
            {
                progress = (double)(_currentContentLength / (double)_expectedContentLength);
            }
            
            [_delegate downloadRequest:self
                currentProgressUpdated:progress
                              received:dataLength
                         totalReceived:_currentContentLength
                      expectedDataSize:_expectedContentLength];
        }
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSUInteger responseCode = _responseStatusCode;
    [self closeConnection];
    if (200 == responseCode || 206 == responseCode || 416 == responseCode)
    {
        NSError *error;
        //remove old file
        if ([[NSFileManager defaultManager] fileExistsAtPath:_finishedFilePath])
        {
            [[NSFileManager defaultManager] removeItemAtPath:_finishedFilePath error:&error];
        }
        //move file
        BOOL moveSuccessed = [[NSFileManager defaultManager] moveItemAtPath:_cacheFilePath toPath:_finishedFilePath error:&error];
        if (moveSuccessed)
        {
            if ([_delegate respondsToSelector:@selector(downloadRequestFinished:)])
            {
                [_delegate downloadRequestFinished:self];
            }
        }
        else
        {
            if ([_delegate respondsToSelector:@selector(downloadRequestWriteFileFailed:)])
            {
                [_delegate downloadRequestWriteFileFailed:self];
            }
        }
    }
    else
    {
        NSError *error = [[NSError alloc] initWithDomain:@"OTHTTPDownloadRequest response code error" code:_responseStatusCode userInfo:nil];
        if ([_delegate respondsToSelector:@selector(downloadRequestFailed:error:)])
        {
            [_delegate downloadRequestFailed:self error:error];
        }
    }
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self closeConnection];
    if ([_delegate respondsToSelector:@selector(downloadRequestFailed:error:)])
    {
        [_delegate downloadRequestFailed:self error:error];
    }
}

@end
