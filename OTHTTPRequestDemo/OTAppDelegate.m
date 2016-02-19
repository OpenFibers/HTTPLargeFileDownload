//
//  OTAppDelegate.m
//  OTHTTPRequestDemo
//
//  Created by openthread on 5/13/13.
//  Copyright (c) 2013 openthread. All rights reserved.
//

#import "OTAppDelegate.h"

#import "HTTPRequestViewController.h"
#import "UploadViewController.h"
#import "DownloadViewController.h"

@implementation OTAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    HTTPRequestViewController *requestController = [[HTTPRequestViewController alloc] init];
    UploadViewController *uploadController = [[UploadViewController alloc] init];
    DownloadViewController *downloadController = [[DownloadViewController alloc] init];
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    tabBarController.viewControllers = @[requestController, uploadController, downloadController];
    self.window.rootViewController = tabBarController;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
