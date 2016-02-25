//
//  OTLivingRequestContainer.m
//  OTHTTPRequestDemo
//
//  Created by openthread on 2/25/16.
//  Copyright © 2016 openthread. All rights reserved.
//

#import "OTLivingRequestContainer.h"

@interface OTLivingRequestContainer ()
@property (nonatomic, strong) NSMutableArray *containerArray;
@end

@implementation OTLivingRequestContainer

+ (instancetype)sharedContainer
{
    static id container = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        container = [[self alloc] init];
    });
    return container;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.containerArray = [NSMutableArray array];
    }
    return self;
}

- (void)addRequest:(id)request
{
    @synchronized(self.containerArray)
    {
        if (![self.containerArray containsObject:request])
        {
            [self.containerArray addObject:request];
        }
    }
}

- (void)removeRequest:(id)request
{
    @synchronized(self.containerArray)
    {
        if ([self.containerArray containsObject:request])
        {
            [self.containerArray removeObject:request];
        }
    }
}

@end
