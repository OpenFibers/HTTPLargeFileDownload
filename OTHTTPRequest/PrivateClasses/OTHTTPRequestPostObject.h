//
//  OTHTTPRequestPostObject.h
//  OTHTTPRequestDemo
//
//  Created by openthread on 2/19/16.
//  Copyright © 2016 openthread. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OTHTTPRequestPostObject : NSObject

//post param key
@property (nonatomic, strong) NSString *key;

//post param value. if post object is a string value, leave fileName MIMEType fileData and filePath nil.
@property (nonatomic, strong) NSString *value;

//if object is a file, this should be file name
@property (nonatomic, strong) NSString *fileName;

//if object is a file, this should be MIME type
@property (nonatomic, strong) NSString *MIMEType;

//if object is a file and send from memory, set data to this property and leave filePath nil
@property (nonatomic, strong) NSData *fileData;

//if object is a file and send from disk, set file path to this property and leave fileData nil
@property (nonatomic, strong) NSString *filePath;

//if object stands for a uploading file
@property (nonatomic, strong) BOOL isFileObject;

//if file at filePath is a normal file, not directory
@property (nonatomic, readonly) BOOL isFileExist;

//if this object is a valid upload object
@property (nonatomic, readonly) BOOL isUploadObject;

@end
