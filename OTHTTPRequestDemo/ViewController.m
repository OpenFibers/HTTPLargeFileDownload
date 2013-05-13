//
//  ViewController.m
//  HTTPLargeFileDownload
//
//  Created by openthread on 12/18/12.
//  Copyright (c) 2012 openthread. All rights reserved.
//

#import "ViewController.h"
#import "OTHTTPDownloadRequest.h"

#define DOWNLOAD_URL        @"http://dl.google.com/drive/installgoogledrive.dmg"

@interface ViewController ()<UITextFieldDelegate,OTHTTPDownloadRequestDelegate>
{
    UITextField *_downloadURLTextField;
    
    UIButton *_startButton;
    UIButton *_pauseButton;
    
    UILabel *_infoLabel;
    
    OTHTTPDownloadRequest *_request;
}
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, 300, 24)];
    label.text = @"Download file at URL:";
    label.backgroundColor = [UIColor clearColor];
    [self.view addSubview:label];
    
    _downloadURLTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    _downloadURLTextField.frame = CGRectMake(10, 54, 300, 24);
    _downloadURLTextField.text = DOWNLOAD_URL;
    _downloadURLTextField.backgroundColor = [UIColor whiteColor];
    _downloadURLTextField.delegate = self;
    _downloadURLTextField.returnKeyType = UIReturnKeyDone;
    [self.view addSubview:_downloadURLTextField];
    
    _startButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _startButton.frame = CGRectMake(10, 100, (320 - 30) / 2, 44);
    [_startButton setTitle:@"Start" forState:UIControlStateNormal];
    [_startButton addTarget:self action:@selector(start) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_startButton];
    
    _pauseButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _pauseButton.frame = CGRectMake(CGRectGetMaxX(_startButton.frame) + 10, 100, _startButton.frame.size.width, 44);
    [_pauseButton setTitle:@"Pause" forState:UIControlStateNormal];
    [_pauseButton addTarget:self action:@selector(pause) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_pauseButton];
    
    _infoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _infoLabel.frame = CGRectMake(10, CGRectGetMaxY(_pauseButton.frame) + 20, 300, 280);
    _infoLabel.numberOfLines = 0;
    [self.view addSubview:_infoLabel];
}

- (void)start
{
    if (!_request)
    {
        NSString *downloadURLString = _downloadURLTextField.text;
        NSString *documentPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        _request = [OTHTTPDownloadRequest requestWithURL:downloadURLString
                                           cacheFilePath:[documentPath stringByAppendingPathComponent:@"temp"]
                                        finishedFilePath:[documentPath stringByAppendingPathComponent:[downloadURLString lastPathComponent]]
                                                delegate:self];
    }
    [_request start];
}

- (void)pause
{
    [_request pause];
}

- (void)downloadRequest:(OTHTTPDownloadRequest *)request
 currentProgressUpdated:(float)progress
               received:(NSUInteger)received
          totalReceived:(long long)totalReceived
       expectedDataSize:(long long)expectedDataSize
{
    NSString *logInfo = [NSString stringWithFormat:
                         @"Download URL:\n%@\nprogress:%f\ndownloaded size:%.2fMB\nexpected size:%.2fMB",
                         [request requestURL],
                         progress,
                         [request downloadedFileSize] / (double) (1024 * 1024),
                         expectedDataSize / (double) (1024 * 1024)];
    _infoLabel.text = logInfo;
}

- (void)downloadRequestFinished:(OTHTTPDownloadRequest *)request
{
    NSString *logInfo = [NSString stringWithFormat:
                         @"Download URL Finished:\n%@\nexpected size:%.2fMB",
                         [request requestURL],
                         [request expectedFileSize] / (double) (1024 * 1024)];
    _infoLabel.text = logInfo;
}

- (void)downloadRequestFailed:(OTHTTPDownloadRequest *)request error:(NSError *)error
{
    NSString *logInfo = [NSString stringWithFormat:
                         @"Download URL Failed:\n%@\n%@",
                         [request requestURL],
                         error];
    _infoLabel.text = logInfo;
}

-(void)downloadRequestWriteFileFailed:(OTHTTPDownloadRequest *)request
{
    NSString *logInfo = [NSString stringWithFormat:
                         @"Write file failed:\n%@",
                         [request cacheFilePath]];
    _infoLabel.text = logInfo;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)dealloc
{
    [_request pause];
}

@end
