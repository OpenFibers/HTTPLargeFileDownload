//
//  OTHTTPRequestUtils.h
//  OTHTTPRequestDemo
//
//  Created by openthread on 2/19/16.
//  Copyright © 2016 openthread. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface OTHTTPRequestUtils : NSObject

/**
 *  URL encode with UTF8
 *
 *  @param stringToEncode string to be URL encoded
 *
 *  @return encoded string
 */
+ (NSString *)urlEncode:(NSString *)stringToEncode;

/**
 *  URL encode with custom string encoding
 *
 *  @param stringToEncode string to be URL encoded
 *  @param encoding       custom string encoding
 *
 *  @return encoded string
 */
+ (NSString *)urlEncode:(NSString *)stringToEncode usingEncoding:(NSStringEncoding)encoding;

/**
 *  URL dncode with UTF8
 *
 *  @param stringToDecode string to be url decoded
 *
 *  @return decoded string
 */
+ (NSString *)urlDecode:(NSString *)stringToDecode; //Decode with UTF8

/**
 *  URL dncode with custom string encoding
 *
 *  @param stringToDecode string to be url decoded
 *  @param encoding       custom string encoding
 *
 *  @return decoded string
 */
+ (NSString *)urlDecode:(NSString *)stringToDecode usingEncoding:(NSStringEncoding)encoding;

/**
 *  Generate params string for get or post request, from dictionary.
 *
 *  @param params Param dictionary to be transform into string.
 *
 *  @return Param string.
 */
+ (NSString *)paramsStringFromParamDictionary:(NSDictionary<NSString *, NSString *> *)params;

/**
 *  Parse GET params from query string. e.g. a=b&c=d
 *
 *  @param queryString the query string to parse
 *
 *  @return Parsed GET params.
 */
+ (NSDictionary<NSString *, NSString *> *)parseGetParamsFromQueryString:(NSString *)queryString;

/**
 *  Parse Get params from URL string
 *
 *  @param urlString URL string to parse.
 *
 *  @return Parsed GET params.
 */
+ (NSDictionary<NSString *, NSString *> *)parseGetParamsFromURLString:(NSString *)urlString;

/**
 *  Get MIME type from file extension
 *
 *  @param fileExtension file extension
 *
 *  @return MIME type
 */
+ (NSString *)MIMETypeForFileExtension:(NSString *)fileExtension;

/**
 *  Get MIME type from file name
 *
 *  @param fileName file name
 *
 *  @return MIME type
 */
+ (NSString *)MIMETypeForFileName:(NSString *)fileName;

@end
