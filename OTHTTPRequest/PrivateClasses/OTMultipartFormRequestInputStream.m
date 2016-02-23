//
//  OTHTTPRequestInputStream.m
//  OTHTTPRequestDemo
//
//  Created by openthread on 2/22/16.
//  Copyright © 2016 openthread. All rights reserved.
//

#import "OTMultipartFormRequestInputStream.h"

@interface OTMultipartFormRequestInputStream () <NSStreamDelegate>
@property (nonatomic, assign) NSStringEncoding encoding;
@property (nonatomic, strong) NSMutableArray *formParts;
@end

@implementation OTMultipartFormRequestInputStream

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


@end
