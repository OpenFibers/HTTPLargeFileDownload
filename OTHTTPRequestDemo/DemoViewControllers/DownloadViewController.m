//
//  ViewController.m
//  HTTPLargeFileDownload
//
//  Created by openthread on 12/18/12.
//  Copyright (c) 2012 openthread. All rights reserved.
//

#import "DownloadViewController.h"
#import "OTHTTPDownloadRequest.h"

static NSString *const DownloadURLString = @"http://dl.google.com/drive/installgoogledrive.dmg";

@interface DownloadViewController ()<UITextFieldDelegate,OTHTTPDownloadRequestDelegate>
{
    UITextField *_downloadURLTextField;
    UIButton *_startButton;
    UIButton *_pauseButton;
    UILabel *_infoLabel;
    
    OTHTTPDownloadRequest *_request;
}
@end

@implementation DownloadViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.title = @"Download";
    }
    return self;
}

- (void)dealloc
{
    [_request pause];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGFloat layoutWidth = CGRectGetWidth(self.view.bounds) - 20;
    UIColor *lightGrayColor = [UIColor colorWithWhite:0 alpha:0.08];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, layoutWidth, 24)];
    label.text = @"Download file at URL:";
    label.backgroundColor = [UIColor clearColor];
    [self.view addSubview:label];
    
    _downloadURLTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    _downloadURLTextField.frame = CGRectMake(10, CGRectGetMaxY(label.frame) + 10, layoutWidth, 24);
    _downloadURLTextField.text = DownloadURLString;
    _downloadURLTextField.backgroundColor = lightGrayColor;
    _downloadURLTextField.delegate = self;
    _downloadURLTextField.returnKeyType = UIReturnKeyDone;
    [self.view addSubview:_downloadURLTextField];
    
    _startButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _startButton.frame = CGRectMake(10, CGRectGetMaxY(_downloadURLTextField.frame) + 10, (layoutWidth - 10) / 2, 44);
    [_startButton setTitle:@"Start" forState:UIControlStateNormal];
    [_startButton addTarget:self action:@selector(start) forControlEvents:UIControlEventTouchUpInside];
    _startButton.backgroundColor = lightGrayColor;
    [self.view addSubview:_startButton];
    
    _pauseButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _pauseButton.frame = CGRectMake(CGRectGetMaxX(_startButton.frame) + 10, CGRectGetMinY(_startButton.frame), _startButton.frame.size.width, 44);
    [_pauseButton setTitle:@"Pause" forState:UIControlStateNormal];
    [_pauseButton addTarget:self action:@selector(pause) forControlEvents:UIControlEventTouchUpInside];
    _pauseButton.backgroundColor = lightGrayColor;
    [self.view addSubview:_pauseButton];
    
    CGFloat infoOriginY = CGRectGetMaxY(_pauseButton.frame) + 10;
    CGFloat infoHeight = CGRectGetHeight(self.view.bounds) - infoOriginY - 10 - 49;
    _infoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _infoLabel.frame = CGRectMake(10, infoOriginY, layoutWidth, infoHeight);
    _infoLabel.numberOfLines = 0;
    _infoLabel.textColor = [UIColor blackColor];
    _infoLabel.backgroundColor = lightGrayColor;
    [self.view addSubview:_infoLabel];
}

- (void)start
{
    if (_request)
    {
        [_request pause];
        _request = nil;
    }
    NSString *downloadURLString = _downloadURLTextField.text;
    NSString *documentPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    _request = [[OTHTTPDownloadRequest alloc] initWithURL:downloadURLString
                                                cacheFile:[documentPath stringByAppendingPathComponent:@"temp"]
                                         finishedFilePath:[documentPath stringByAppendingPathComponent:[downloadURLString lastPathComponent]]];
    _request.delegate = self;
    [_request start];
}

- (void)pause
{
    [_request pause];
}

- (void)downloadRequest:(OTHTTPDownloadRequest *)request
 currentProgressUpdated:(float)progress
                  speed:(float)bytesPerSecond
          totalReceived:(long long)totalReceived
       expectedDataSize:(long long)expectedDataSize
{
    NSString *logInfo = [NSString stringWithFormat:
                         @"Download URL:\n%@\nprogress:%.2f %%\n\ndownloaded size:%.2fMB\n\nexpected size:%.2fMB\n\ncurrent speed:%.2f MB/s",
                         [request requestURL],
                         progress * 100,
                         [request downloadedFileSize] / (double) (1024 * 1024),
                         expectedDataSize / (double) (1024 * 1024),
                         request.averageDownloadSpeed / (double) (1024 * 1024)];
    _infoLabel.text = logInfo;
}

- (void)downloadRequestFinished:(OTHTTPDownloadRequest *)request
{
    NSString *logInfo = [NSString stringWithFormat:
                         @"Download URL Finished:\n%@\n\nexpected size:%.2fMB",
                         [request requestURL],
                         [request expectedFileSize] / (double) (1024 * 1024)];
    _infoLabel.text = logInfo;
}

- (void)downloadRequestFailed:(OTHTTPDownloadRequest *)request error:(NSError *)error
{
    NSString *logInfo = [NSString stringWithFormat:
                         @"Download URL Failed:\n%@\n\n%@",
                         [request requestURL],
                         error];
    _infoLabel.text = logInfo;
}

-(void)downloadRequestWriteFileFailed:(OTHTTPDownloadRequest *)request exception:(NSException *)exception
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

@end
