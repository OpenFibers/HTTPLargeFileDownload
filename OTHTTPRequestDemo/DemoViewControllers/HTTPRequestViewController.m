//
//  HTTPRequestViewController.m
//  OTHTTPRequestDemo
//
//  Created by openthread on 2/19/16.
//  Copyright © 2016 openthread. All rights reserved.
//

#import "HTTPRequestViewController.h"
#import "OTHTTPRequest.h"

static NSString * const RequestURLString = @"https://www.google.com";

@interface HTTPRequestViewController () <OTHTTPRequestDelegate, UITextFieldDelegate>

@end

@implementation HTTPRequestViewController
{
    UITextField *_requestURLTextField;
    UIButton *_startButton;
    UIButton *_cancelButton;
    UITextView *_infoView;
    
    OTHTTPRequest *_request;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.title = @"Request";
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
    label.text = @"Download file at URL:";
    label.backgroundColor = [UIColor clearColor];
    [self.view addSubview:label];
    
    _requestURLTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    _requestURLTextField.frame = CGRectMake(10, CGRectGetMaxY(label.frame) + 10, layoutWidth, 24);
    _requestURLTextField.text = RequestURLString;
    _requestURLTextField.backgroundColor = lightGrayColor;
    _requestURLTextField.delegate = self;
    _requestURLTextField.returnKeyType = UIReturnKeyDone;
    [self.view addSubview:_requestURLTextField];
    
    _startButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _startButton.frame = CGRectMake(10, CGRectGetMaxY(_requestURLTextField.frame) + 10, (layoutWidth - 10) / 2, 44);
    [_startButton setTitle:@"Start" forState:UIControlStateNormal];
    [_startButton addTarget:self action:@selector(start) forControlEvents:UIControlEventTouchUpInside];
    _startButton.backgroundColor = lightGrayColor;
    [self.view addSubview:_startButton];
    
    _cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _cancelButton.frame = CGRectMake(CGRectGetMaxX(_startButton.frame) + 10, CGRectGetMinY(_startButton.frame), _startButton.frame.size.width, 44);
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

- (void)start
{
    if (_request)
    {
        [_request cancel];
        _request = nil;
    }
    NSString *downloadURLString = _requestURLTextField.text;
    _request = [[OTHTTPRequest alloc] initWithURL:[NSURL URLWithString:downloadURLString]];
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
    NSLog(@"Request finished with response string:\n%@", responseString);
}

- (void)otHTTPRequestFailed:(OTHTTPRequest *)request error:(NSError *)error
{
    NSLog(@"Request failed with error: %@", error);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
