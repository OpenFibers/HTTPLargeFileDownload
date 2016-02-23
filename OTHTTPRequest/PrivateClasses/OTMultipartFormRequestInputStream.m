//
//  OTHTTPRequestInputStream.m
//  OTHTTPRequestDemo
//
//  Created by openthread on 2/22/16.
//  Copyright © 2016 openthread. All rights reserved.
//

#import "OTMultipartFormRequestInputStream.h"
#import "OTMultipartFormRequestBodyPart.h"

@interface OTMultipartFormRequestInputStream () <NSStreamDelegate>
@property (nonatomic, readwrite) NSStreamStatus streamStatus;
@property (nonatomic, assign) NSStringEncoding encoding;
@property (nonatomic, strong) NSMutableArray *formParts;
@end

@implementation OTMultipartFormRequestInputStream
@synthesize streamStatus = _streamStatus;
@synthesize delegate = _delegate;

- (instancetype)initWithEncoding:(NSStringEncoding)encoding
{
    self = [super init];
    if (self)
    {
        if (encoding == 0 || encoding == 0xffffffff || encoding == NSNotFound)
        {
            self.encoding = NSUTF8StringEncoding;
        }
        self.encoding = encoding;
    }
    return self;
}

- (instancetype)init
{
    self = [self initWithEncoding:NSUTF8StringEncoding];
    return self;
}

- (unsigned long long)setupHTTPBodyWithObjects:(NSArray<OTHTTPRequestPostObject *> *)objects boundary:(NSString *)boundary
{
    return 0;
}

- (NSInteger)read:(uint8_t *)buffer maxLength:(NSUInteger)length
{
    if ([self streamStatus] == NSStreamStatusClosed)
    {
        return 0;
    }
    NSInteger totalNumberOfBytesRead = 0;
//    while ((NSUInteger)totalNumberOfBytesRead < MIN(length, self.numberOfBytesInPacket))
//    {
//        if (!self.currentHTTPBodyPart || ![self.currentHTTPBodyPart hasBytesAvailable])
//        {
//            if (!(self.currentHTTPBodyPart = [self.HTTPBodyPartEnumerator nextObject]))
//            {
//                break;
//            }
//        }
//        else
//        {
//            NSUInteger maxLength = length - (NSUInteger)totalNumberOfBytesRead;
//            NSInteger numberOfBytesRead = [self.currentHTTPBodyPart read:&buffer[totalNumberOfBytesRead] maxLength:maxLength];
//            if (numberOfBytesRead == -1)
//            {
//                self.streamError = self.currentHTTPBodyPart.inputStream.streamError;
//                break;
//            }
//            else
//            {
//                totalNumberOfBytesRead += numberOfBytesRead;
//            }
//        }
//    }
    return totalNumberOfBytesRead;
}

- (BOOL)getBuffer:(uint8_t * _Nullable *)buffer length:(NSUInteger *)len
{
    return NO;
}

- (BOOL)hasBytesAvailable
{
    return [self streamStatus] == NSStreamStatusOpen;
}

- (void)open
{
    if (self.streamStatus == NSStreamStatusOpen)
    {
        return;
    }
    
    self.streamStatus = NSStreamStatusOpen;
}

- (void)close
{
    self.streamStatus = NSStreamStatusClosed;
}

- (id)propertyForKey:(NSString *)key
{
    return nil;
}

- (BOOL)setProperty:(id)property forKey:(NSString *)key
{
    return NO;
}

- (void)scheduleInRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode
{
}

- (void)removeFromRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode
{
}

@end
