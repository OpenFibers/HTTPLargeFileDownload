//
//  UploadViewController.m
//  OTHTTPRequestDemo
//
//  Created by openthread on 2/19/16.
//  Copyright © 2016 openthread. All rights reserved.
//

#import "UploadViewController.h"
#import "OTHTTPRequest.h"

static NSString * const RequestURLString = @"https://www.google.com";

@interface UploadViewController() <OTHTTPRequestDelegate, UITextFieldDelegate>

@end

@implementation UploadViewController
{
    UITextField *_requestURLTextField;
    UIButton *_uploadButton;
    UIButton *_cancelButton;
    UITextView *_infoView;
    
    OTHTTPRequest *_request;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.title = @"Upload";
    }
    return self;
}

- (void)dealloc
{
    [_request cancel];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGFloat layoutWidth = CGRectGetWidth(self.view.bounds) - 20;
    UIColor *lightGrayColor = [UIColor colorWithWhite:0 alpha:0.08];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, layoutWidth, 24)];
    label.text = @"Upload file to URL:";
    label.backgroundColor = [UIColor clearColor];
    [self.view addSubview:label];
    
    _requestURLTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    _requestURLTextField.frame = CGRectMake(10, CGRectGetMaxY(label.frame) + 10, layoutWidth, 24);
    _requestURLTextField.text = RequestURLString;
    _requestURLTextField.backgroundColor = lightGrayColor;
    _requestURLTextField.delegate = self;
    _requestURLTextField.returnKeyType = UIReturnKeyDone;
    [self.view addSubview:_requestURLTextField];
    
    _uploadButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _uploadButton.frame = CGRectMake(10, CGRectGetMaxY(_requestURLTextField.frame) + 10, (layoutWidth - 10) / 2, 44);
    [_uploadButton setTitle:@"Upload" forState:UIControlStateNormal];
    [_uploadButton addTarget:self action:@selector(upload) forControlEvents:UIControlEventTouchUpInside];
    _uploadButton.backgroundColor = lightGrayColor;
    [self.view addSubview:_uploadButton];
    
    _cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _cancelButton.frame = CGRectMake(CGRectGetMaxX(_uploadButton.frame) + 10, CGRectGetMinY(_uploadButton.frame), _uploadButton.frame.size.width, 44);
    [_cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [_cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    _cancelButton.backgroundColor = lightGrayColor;
    [self.view addSubview:_cancelButton];
    
    CGFloat infoOriginY = CGRectGetMaxY(_cancelButton.frame) + 10;
    CGFloat infoHeight = CGRectGetHeight(self.view.bounds) - infoOriginY - 10 - 49;
    _infoView = [[UITextView alloc] initWithFrame:CGRectZero];
    _infoView.frame = CGRectMake(10, infoOriginY, layoutWidth, infoHeight);
    _infoView.textColor = [UIColor blackColor];
    _infoView.backgroundColor = lightGrayColor;
    _infoView.font = [UIFont systemFontOfSize:11];
    _infoView.editable = NO;
    [self.view addSubview:_infoView];
}

- (void)upload
{
    if (_request)
    {
        [_request cancel];
        _request = nil;
    }
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Default" ofType:@"png"];
    
    NSString *downloadURLString = _requestURLTextField.text;
    _request = [[OTHTTPRequest alloc] initWithURL:[NSURL URLWithString:downloadURLString]];
    [_request addPostValue:@"post_value" forKey:@"key"];
    [_request addFileForKey:@"file" filePath:filePath fileName:@"Default.png" MIMEType:nil];
    _request.delegate = self;
    [_request start];
}

- (void)cancel
{
    [_request cancel];
}

- (void)otHTTPRequestFinished:(OTHTTPRequest *)request
{
    NSString *responseString = request.responseString;
    _infoView.text = responseString;
}

- (void)otHTTPRequestFailed:(OTHTTPRequest *)request error:(NSError *)error
{
    NSString *errorString = [NSString stringWithFormat:@"Request failed with error: %@", error];
    _infoView.text = errorString;
}

- (void)otHTTPRequest:(OTHTTPRequest *)request uploadProgressUpdated:(float)uploadProgress speed:(float)bytesPerSecond bytesSent:(unsigned long long)totalSent contentLength:(unsigned long long)contentLength
{
    NSString *logInfo = [NSString stringWithFormat:
                         @"Upload URL:\n%@\nprogress:%.2f %%\n\nuploaded size:%.2fKB\n\nexpected size:%.2fKB\n\ncurrent speed:%.2f KB/s",
                         [request URL],
                         uploadProgress * 100,
                         totalSent / (double) (1024),
                         contentLength / (double) (1024),
                         request.averageUploadSpeed / (double) (1024)];
    _infoView.text = logInfo;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
