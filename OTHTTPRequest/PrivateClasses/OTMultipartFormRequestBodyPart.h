//
//  OTMultipartFormRequestBodyPart.h
//  OTHTTPRequestDemo
//
//  Created by openthread on 2/23/16.
//  Copyright © 2016 openthread. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OTMultipartFormRequestBodyPart : NSObject

- (nullable instancetype)initWithData:(nonnull NSData *)data;
- (nullable instancetype)initWithString:(nonnull NSString *)string encoding:(NSStringEncoding)encoding;
- (nullable instancetype)initWithFilePath:(nonnull NSString *)filePath;

@property (nonatomic, readonly) unsigned long long length;

- (void)resetReadHandleAndOffset;

- (NSInteger)read:(nonnull uint8_t *)buffer maxLength:(NSUInteger)length;

- (BOOL)hasReadToEnd;

- (nullable NSError *)streamError;

@end
