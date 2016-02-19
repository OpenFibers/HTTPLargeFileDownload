//
//  OTHTTPRequestPostObject.m
//  OTHTTPRequestDemo
//
//  Created by openthread on 2/19/16.
//  Copyright © 2016 openthread. All rights reserved.
//

#import "OTHTTPRequestPostObject.h"

@implementation OTHTTPRequestPostObject
{
    NSString *_key;
    NSString *_value;
}

- (NSString *)key
{
    return _key ?: @"";
}

- (void)setKey:(NSString *)key
{
    _key = key;
}

- (NSString *)value
{
    return _value ?: @"";
}

- (void)setValue:(NSString *)value
{
    _value = value;
}

- (BOOL)isUploadObject
{
    return self.fileData.length != 0 || self.filePath.length != 0;
}

@end
