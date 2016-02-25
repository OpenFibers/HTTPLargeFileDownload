//
//  OTLivingRequestContainer.h
//  OTHTTPRequestDemo
//
//  Created by openthread on 2/25/16.
//  Copyright © 2016 openthread. All rights reserved.
//
//  Added living request to container, incase they won't dealloc if working

#import <Foundation/Foundation.h>

@interface OTLivingRequestContainer : NSObject

+ (instancetype)sharedContainer;

- (void)addRequest:(id)request;

- (void)removeRequest:(id)request;

@end
