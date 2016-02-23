//
//  OTHTTPRequestInputStream.h
//  OTHTTPRequestDemo
//
//  Created by openthread on 2/22/16.
//  Copyright © 2016 openthread. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTHTTPRequestPostObject.h"

@interface OTMultipartFormRequestInputStream : NSInputStream

/**
 *  Init a input stream with encoding. If an invalid encoding given, will init with NSUTF8StringEncoding.
 *
 *  @param encoding The specific encoding of body
 *
 *  @return Input stream instance.
 */
- (nonnull instancetype)initWithEncoding:(NSStringEncoding)encoding;

/**
 *  Setup multipart form body
 *
 *  @param objects  OTHTTPRequestPostObjects
 *  @param boundary Boundary of multipart form
 *
 *  @return The length of body content
 */
- (unsigned long long)setupHTTPBodyWithObjects:(nullable NSArray<OTHTTPRequestPostObject *> *)objects boundary:(nonnull NSString *)boundary;

@end
