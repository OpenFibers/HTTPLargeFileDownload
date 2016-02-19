//
//  OTHTTPRequestUtils.m
//  OTHTTPRequestDemo
//
//  Created by openthread on 2/19/16.
//  Copyright © 2016 openthread. All rights reserved.
//

#import "OTHTTPRequestUtils.h"

@implementation OTHTTPRequestUtils

+ (NSString *)urlEncode:(NSString *)stringToEncode
{
    return [self urlEncode:stringToEncode usingEncoding:NSUTF8StringEncoding];
}

+ (NSString *)urlEncode:(NSString *)stringToEncode usingEncoding:(NSStringEncoding)encoding
{
    return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                 (__bridge CFStringRef)stringToEncode,
                                                                                 NULL,
                                                                                 (CFStringRef) @"!*'\"();:@&=+$,/?%#[]% ",
                                                                                 CFStringConvertNSStringEncodingToEncoding(encoding));
}

+ (NSString *)urlDecode:(NSString *)stringToDecode
{
    return [self urlDecode:stringToDecode usingEncoding:NSUTF8StringEncoding];
}

+ (NSString *)urlDecode:(NSString *)stringToDecode usingEncoding:(NSStringEncoding)encoding
{
    return (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,
                                                                                                 (__bridge CFStringRef)stringToDecode,
                                                                                                 (CFStringRef) @"",
                                                                                                 CFStringConvertNSStringEncodingToEncoding(encoding));
}

+ (NSString *)paramsStringFromParamDictionary:(NSDictionary<NSString *, NSString *> *)params;
{
    NSMutableString *paramString = [NSMutableString string];
    for (id key in params.allKeys)
    {
        if ([key isKindOfClass:[NSString class]])
        {
            NSString *value = params[key];
            if ([value isKindOfClass:[NSString class]])
            {
                [paramString appendString:[self urlEncode:key]];
                [paramString appendString:@"="];
                [paramString appendString:[self urlEncode:value]];
                
                if ([params.allKeys lastObject] != key)
                {
                    [paramString appendString:@"&"];
                }
            }
        }
    }
    return [NSString stringWithString:paramString];
}

+ (NSDictionary<NSString *, NSString *> *)parseGetParamsFromQueryString:(NSString *)queryString
{
    NSArray *components = [queryString componentsSeparatedByString:@"&"];
    NSMutableDictionary *resultDic = [NSMutableDictionary dictionary];
    for (NSString *string in components)
    {
        NSRange equalRange = [string rangeOfString:@"="];
        if (equalRange.location == NSNotFound)
        {
            continue;
        }
        NSString *key = [string substringToIndex:equalRange.location];
        NSString *value = [string substringFromIndex:equalRange.location + equalRange.length];
        [resultDic setObject:value forKey:key];
    }
    
    NSDictionary *returnDic = [NSDictionary dictionaryWithDictionary:resultDic];
    return returnDic;
}

+ (NSDictionary<NSString *, NSString *> *)parseGetParamsFromURLString:(NSString *)urlString
{
    if (!urlString)
    {
        return nil;
    }
    
    NSURL *URL = [NSURL URLWithString:urlString];
    NSString *queryString = URL.query;
    if (queryString.length == 0)
    {
        return nil;
    }
    
    NSDictionary *result = [self parseGetParamsFromQueryString:queryString];
    return result;
}

+ (NSString *)MIMETypeForFileExtension:(NSString *)fileExtension
{
    NSString *const defaultMIMEType = @"application/octet-stream";
    if (fileExtension.length == 0)
    {
        return defaultMIMEType;
    }
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)fileExtension, NULL);
    CFStringRef MIMEType = UTTypeCopyPreferredTagWithClass (UTI, kUTTagClassMIMEType);
    CFRelease(UTI);
    NSString *MIMETypetring = (NSString *)CFBridgingRelease(MIMEType);
    if (MIMETypetring.length == 0)
    {
        return defaultMIMEType;
    }
    return MIMETypetring;
}

+ (NSString *)MIMETypeForFileName:(NSString *)fileName
{
    NSString *extension = [fileName pathExtension];
    NSString *MIMEType = [self MIMETypeForFileExtension:extension];
    return MIMEType;
}

@end
