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
+ (nonnull NSString *)urlEncode:(nonnull NSString *)stringToEncode;

/**
 *  URL encode with custom string encoding
 *
 *  @param stringToEncode string to be URL encoded
 *  @param encoding       custom string encoding
 *
 *  @return encoded string
 */
+ (nonnull NSString *)urlEncode:(nonnull NSString *)stringToEncode usingEncoding:(NSStringEncoding)encoding;

/**
 *  URL dncode with UTF8
 *
 *  @param stringToDecode string to be url decoded
 *
 *  @return decoded string, NULL if the percent escapes cannot be converted to characters, assuming UTF8 encoding
 */
+ (nullable NSString *)urlDecode:(nonnull NSString *)stringToDecode; //Decode with UTF8

/**
 *  URL decode with custom string encoding
 *
 *  @param stringToDecode string to be url decoded
 *  @param encoding       custom string encoding
 *
 *  @return decoded string, NULL if the percent escapes cannot be converted to characters, assuming the encoding given by encoding
 */
+ (nullable NSString *)urlDecode:(nonnull NSString *)stringToDecode usingEncoding:(NSStringEncoding)encoding;

/**
 *  Generate params string for get or post request, from dictionary.
 *
 *  @param params Param dictionary to be transform into string.
 *
 *  @return Param string.
 */
+ (nonnull NSString *)paramsStringFromParamDictionary:(nullable NSDictionary<NSString *, NSString *> *)params;

/**
 *  Parse GET params from query string. e.g. a=b&c=d
 *
 *  @param queryString the query string to parse
 *
 *  @return Parsed GET params.
 */
+ (nullable NSDictionary<NSString *, NSString *> *)parseGetParamsFromQueryString:(nullable NSString *)queryString;

/**
 *  Parse Get params from URL string
 *
 *  @param urlString URL string to parse.
 *
 *  @return Parsed GET params.
 */
+ (nullable NSDictionary<NSString *, NSString *> *)parseGetParamsFromURLString:(nullable NSString *)urlString;

/**
 *  Get MIME type from file extension
 *
 *  @param fileExtension file extension
 *
 *  @return MIME type
 */
+ (nonnull NSString *)MIMETypeForFileExtension:(nullable NSString *)fileExtension;

/**
 *  Get MIME type from file name
 *
 *  @param fileName file name
 *
 *  @return MIME type
 */
+ (nonnull NSString *)MIMETypeForFileName:(nullable NSString *)fileName;

/**
 *  Get encoding Name for NSStringEncoding.
 *
 *  @param stringEncoding A specific NSStringEncoding.
 *
 *  @return Converted name of encoding. Return nil if stringEncoding is illegal.
 */
+ (nullable NSString *)encodingNameFromNSStringEncoding:(NSStringEncoding)stringEncoding;

/**
 *  Get NSStringEncoding for encoding name
 *
 *  @param encodingName Encoding name string
 *
 *  @return Converted NSStringEncoding. Return 0 if encodingName not recognized.
 */
+ (NSStringEncoding)NSStringEncodingFromEncodingName:(nonnull NSString *)encodingName;

/**
 *  Get encoding name for HTTP content type (often from request header's content type)
 *
 *  @param contentType HTTP content type
 *
 *  @return Encoding name. Return nil if content type not recognized.
 */
+ (nullable NSString *)encodingNameFromHTTPContentType:(nonnull NSString *)contentType;

/**
 *  Generate content type for text request with encoding name string
 *
 *  @param encodingName Encoding name
 *
 *  @return The generated content type for HTTP request header, "text/html; charset=%@".
 */
+ (nonnull NSString *)HTTPTextContentTypeForEncodingName:(nonnull NSString *)encodingName;

/**
 *  Generate content type for multipart/form request with encoding name string and boundary
 *
 *  @param encodingName Encoding name
 *  @param boundary     Boundary of http body
 *
 *  @return The generated content type for HTTP request header, "multipart/form-data; charset=%@; boundary=%@".
 */
+ (nonnull NSString *)HTTPMultipartContentTypeForEncodingName:(nonnull NSString *)encodingName boundary:(nonnull NSString *)boundary;

@end
