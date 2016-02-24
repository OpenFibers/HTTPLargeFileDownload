//
//  OTMultipartFormRequestBodyPart.m
//  OTHTTPRequestDemo
//
//  Created by openthread on 2/23/16.
//  Copyright © 2016 openthread. All rights reserved.
//

#import "OTMultipartFormRequestBodyPart.h"

@interface OTMultipartFormRequestBodyPart()
@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) NSString *filePath;
@end

@implementation OTMultipartFormRequestBodyPart

- (instancetype)init
{
    self = [super init];
    return self;
}

- (nullable instancetype)initWithData:(nonnull NSData *)data
{
    if (!data)
    {
        return nil;
    }
    self = [self init];
    if (self)
    {
        self.data = data;
    }
    return self;
}

- (nullable instancetype)initWithString:(nonnull NSString *)string encoding:(NSStringEncoding)encoding
{
    if (!string)
    {
        return nil;
    }
    self = [self init];
    if (self)
    {
        NSData *data = [string dataUsingEncoding:encoding];
        self.data = data;
    }
    return self;
}

- (nullable instancetype)initWithFilePath:(nonnull NSString *)filePath
{
    BOOL isDirectory = NO;
    BOOL fileExist = [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory];
    if (!fileExist || isDirectory)
    {
        return nil;
    }
    self = [self init];
    if (self)
    {
        self.filePath = filePath;
    }
    return self;
}

- (void)resetReadHandleAndOffset
{
    
}

- (NSInteger)read:(uint8_t *)buffer maxLength:(NSUInteger)length
{
    return 0;
}

@end
