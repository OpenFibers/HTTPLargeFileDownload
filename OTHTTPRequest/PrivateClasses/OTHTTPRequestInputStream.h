//
//  OTHTTPRequestInputStream.h
//  OTHTTPRequestDemo
//
//  Created by openthread on 2/22/16.
//  Copyright © 2016 openthread. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTHTTPRequestPostObject.h"

@interface OTHTTPRequestInputStream : NSInputStream

- (void)setupHTTPBodyWithObjects:(NSArray<OTHTTPRequestPostObject *> *)objects;

@end
