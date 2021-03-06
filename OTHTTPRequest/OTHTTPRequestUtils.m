//
//  OTHTTPRequestUtils.m
//  OTHTTPRequestDemo
//
//  Created by openthread on 2/19/16.
//  Copyright © 2016 openthread. All rights reserved.
//

#import "OTHTTPRequestUtils.h"

@implementation OTHTTPRequestUtils

+ (nonnull NSString *)urlEncode:(nonnull NSString *)stringToEncode
{
    return [self urlEncode:stringToEncode usingEncoding:NSUTF8StringEncoding];
}

+ (nonnull NSString *)urlEncode:(nonnull NSString *)stringToEncode usingEncoding:(NSStringEncoding)encoding
{
    return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                 (__bridge CFStringRef)stringToEncode,
                                                                                 NULL,
                                                                                 (CFStringRef) @"!*'\"();:@&=+$,/?%#[]% ",
                                                                                 CFStringConvertNSStringEncodingToEncoding(encoding));
}

+ (nullable NSString *)urlDecode:(nonnull NSString *)stringToDecode; //Decode with UTF8
{
    return [self urlDecode:stringToDecode usingEncoding:NSUTF8StringEncoding];
}

+ (nullable NSString *)urlDecode:(nonnull NSString *)stringToDecode usingEncoding:(NSStringEncoding)encoding
{
    return (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,
                                                                                                 (__bridge CFStringRef)stringToDecode,
                                                                                                 (CFStringRef) @"",
                                                                                                 CFStringConvertNSStringEncodingToEncoding(encoding));
}

+ (nonnull NSString *)paramsStringFromParamDictionary:(nullable NSDictionary<NSString *, NSString *> *)params
{
    return [self paramsStringFromParamDictionary:params encoding:NSUTF8StringEncoding];
}

+ (nonnull NSString *)paramsStringFromParamDictionary:(nullable NSDictionary<NSString *, NSString *> *)params
                                             encoding:(NSStringEncoding)encoding
{
    NSMutableString *paramString = [NSMutableString string];
    for (id key in params.allKeys)
    {
        if ([key isKindOfClass:[NSString class]])
        {
            NSString *value = params[key];
            if ([value isKindOfClass:[NSString class]])
            {
                [paramString appendString:[self urlEncode:key usingEncoding:encoding]];
                [paramString appendString:@"="];
                [paramString appendString:[self urlEncode:value usingEncoding:encoding]];
                
                if ([params.allKeys lastObject] != key)
                {
                    [paramString appendString:@"&"];
                }
            }
        }
    }
    return [NSString stringWithString:paramString];
}

+ (nullable NSDictionary<NSString *, NSString *> *)parseGetParamsFromQueryString:(nullable NSString *)queryString
{
    if (!queryString)
    {
        return nil;
    }
    
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
        value = [self urlDecode:value];
        [resultDic setObject:value forKey:key];
    }
    
    NSDictionary *returnDic = [NSDictionary dictionaryWithDictionary:resultDic];
    return returnDic;
}

+ (nullable NSDictionary<NSString *, NSString *> *)parseGetParamsFromURLString:(nullable NSString *)urlString
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

+ (nonnull NSString *)MIMETypeForFileExtension:(nullable NSString *)fileExtension
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

+ (nonnull NSString *)MIMETypeForFileName:(nullable NSString *)fileName
{
    NSString *extension = [fileName pathExtension];
    NSString *MIMEType = [self MIMETypeForFileExtension:extension];
    return MIMEType;
}

+ (nullable NSString *)encodingNameFromNSStringEncoding:(NSStringEncoding)stringEncoding
{
    CFStringEncoding cfStringEncoding = CFStringConvertNSStringEncodingToEncoding(stringEncoding);
    CFStringRef encodingNameRef = CFStringConvertEncodingToIANACharSetName(cfStringEncoding);
    NSString *encoding = (__bridge NSString *)encodingNameRef;
    return encoding;
}

+ (NSStringEncoding)NSStringEncodingFromEncodingName:(nonnull NSString *)encodingName
{
    if (encodingName.length == 0)
    {
        return 0;
    }
    CFStringRef encodingNameRef = (__bridge CFStringRef)encodingName;
    CFStringEncoding stringEncodingRef = CFStringConvertIANACharSetNameToEncoding(encodingNameRef);
    NSStringEncoding stringEncoding = CFStringConvertEncodingToNSStringEncoding(stringEncodingRef);
    return stringEncoding;
}

+ (nullable NSString *)encodingNameFromHTTPContentType:(nonnull NSString *)contentType
{
    if (contentType.length == 0)
    {
        return nil;
    }
    
    //remove all white space, and convert to lower case
    NSArray *words = [contentType componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *noSpaceString = [words componentsJoinedByString:@""];
    noSpaceString = [noSpaceString lowercaseString];

    //separate from ; and ,
    //then get the component begin with charset=
    NSArray *components = [noSpaceString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@";,"]];
    NSString *const charsetPrefix = @"charset=";
    NSString *encodingName = nil;
    for (NSString *eachComponent in components)
    {
        //check if has prefix charset=
        if ([eachComponent hasPrefix:charsetPrefix])
        {
            NSString *charsetValue = [eachComponent substringFromIndex:charsetPrefix.length];
            if (charsetValue.length != 0)
            {
                encodingName = charsetValue;
                break;
            }
        }
    }
    return encodingName;
}

+ (nonnull NSString *)HTTPWWWFormTypeForEncodingName:(nonnull NSString *)encodingName
{
    if (!encodingName)
    {
        return @"";
    }
    NSString *result = [NSString stringWithFormat:@"application/x-www-form-urlencoded; charset=%@", encodingName ?: @""];
    return result;
}

+ (nonnull NSString *)HTTPMultipartContentTypeForEncodingName:(nonnull NSString *)encodingName boundary:(nonnull NSString *)boundary
{
    if (!encodingName || !boundary)
    {
        return @"";
    }
    NSString *result = [NSString stringWithFormat:@"multipart/form-data; charset=%@; boundary=%@", encodingName, boundary];
    return result;
}

@end
