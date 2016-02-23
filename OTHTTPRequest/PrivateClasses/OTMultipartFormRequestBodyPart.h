//
//  OTMultipartFormRequestBodyPart.h
//  OTHTTPRequestDemo
//
//  Created by openthread on 2/23/16.
//  Copyright © 2016 openthread. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OTMultipartFormRequestBodyPart : NSObject

@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, assign) unsigned long long length;

@end
