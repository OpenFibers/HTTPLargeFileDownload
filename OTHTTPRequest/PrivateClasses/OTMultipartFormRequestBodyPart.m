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
@property (nonatomic, assign) unsigned long long bytesHasRead;
@property (nonatomic, strong) NSInputStream *fileReadStream;
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
        _length = data.length;
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
        _length = data.length;
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
        NSError *error;
        unsigned long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&error] fileSize];
        if (!error)
        {
            _length = fileSize;
        }
        else
        {
            _length = 0;
        }
    }
    return self;
}

- (void)dealloc
{
    [self resetReadHandleAndOffset];
}

- (void)resetReadHandleAndOffset
{
    [self.fileReadStream close];
    self.fileReadStream = nil;
    self.bytesHasRead = 0;
}

- (NSInteger)read:(uint8_t *)buffer maxLength:(NSUInteger)length
{
    if (self.data)
    {
        return [self readData:buffer maxLength:length];
    }
    else
    {
        return [self readFile:buffer maxLength:length];
    }
    return 0;
}

- (NSInteger)readData:(uint8_t *)buffer maxLength:(NSUInteger)length
{
    NSUInteger rangeLength = MIN(self.length - self.bytesHasRead, length);
    NSRange readRange = NSMakeRange(self.bytesHasRead, rangeLength);
    [self.data getBytes:buffer range:readRange];
    self.bytesHasRead += rangeLength;
    return rangeLength;
}

- (NSInteger)readFile:(uint8_t *)buffer maxLength:(NSUInteger)length
{
    if (!self.fileReadStream)
    {
        self.fileReadStream = [[NSInputStream alloc] initWithFileAtPath:self.filePath];
        [self.fileReadStream open];
    }
    
    NSInteger bytesRead = [self.fileReadStream read:buffer maxLength:length];
    self.bytesHasRead += bytesRead;
    if (self.bytesHasRead == self.length)
    {
        [self.fileReadStream close];
    }
    
    return bytesRead;
}

@end
