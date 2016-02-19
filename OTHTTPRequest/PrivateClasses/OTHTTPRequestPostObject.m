//
//  OTHTTPRequestPostObject.m
//  OTHTTPRequestDemo
//
//  Created by openthread on 2/19/16.
//  Copyright © 2016 openthread. All rights reserved.
//

#import "OTHTTPRequestPostObject.h"
#import "OTHTTPRequestUtils.h"

@implementation OTHTTPRequestPostObject
{
    NSString *_key;
    NSString *_value;
    NSString *_fileName;
    NSString *_MIMEType;
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

- (NSString *)fileName
{
    if (_fileName)
    {
        return _fileName;
    }
    if (self.filePath.length)
    {
        return self.filePath.lastPathComponent;
    }
    return nil;
}

- (void)setFileName:(NSString *)fileName
{
    _fileName = fileName;
}

- (NSString *)MIMEType
{
    if (_MIMEType.length)
    {
        return _MIMEType;
    }
    
    NSString *MIMEType = [OTHTTPRequestUtils MIMETypeForFileExtension:self.fileName];
    return MIMEType;
}

- (void)setMIMEType:(NSString *)MIMEType
{
    _MIMEType = MIMEType;
}

- (BOOL)isUploadObject
{
    return self.fileData.length != 0 || self.filePath.length != 0;
}

@end
