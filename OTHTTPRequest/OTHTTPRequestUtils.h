//
//  OTHTTPRequestUtils.h
//  OTHTTPRequestDemo
//
//  Created by openthread on 2/19/16.
//  Copyright © 2016 openthread. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OTHTTPRequestUtils : NSObject

+ (NSString *)urlEncode:(NSString *)stringToEncode; //Encode with UTF8
+ (NSString *)urlEncode:(NSString *)stringToEncode usingEncoding:(NSStringEncoding)encoding;

+ (NSString *)urlDecode:(NSString *)stringToDecode; //Decode with UTF8
+ (NSString *)urlDecode:(NSString *)stringToDecode usingEncoding:(NSStringEncoding)encoding;

/**
 *  Generate params string for get or post request, from dictionary.
 *
 *  @param params Param dictionary to be transform into string.
 *
 *  @return Param string.
 */
+ (NSString *)paramsStringFromParamDictionary:(NSDictionary *)params;

/**
 *  Parse params from get url request
 *
 *  @param urlString URL string to be parsed.
 *
 *  @return The result of parsing.
 */
+ (NSDictionary *)parseGetParamsFromURLString:(NSString *)urlString;

@end
