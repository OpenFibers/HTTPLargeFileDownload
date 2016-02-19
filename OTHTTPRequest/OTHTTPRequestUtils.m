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

+ (NSDictionary<NSString *, NSString *> *)parseGetParamsFromURLString:(NSString *)urlString
{
    if (!urlString)
    {
        return nil;
    }
    NSRange queryRange = [urlString rangeOfString:@"?"];
    if (queryRange.location == NSNotFound)
    {
        return nil;
    }
    
    NSString *subString = [urlString substringFromIndex:queryRange.location + queryRange.length];
    NSArray *components = [subString componentsSeparatedByString:@"&"];
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

@end
