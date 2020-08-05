//
//  YBAppDelegate.m
//  YBMediaPlayer
//
//  Created by Sun on 01/03/2020.
//  Copyright (c) 2020 QingClass. All rights reserved.
//

#import "YBAppDelegate.h"
#import "YBPlayerNavigationController.h"
#import "YBPlayerListViewController.h"

@implementation YBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _window.rootViewController = [[YBPlayerNavigationController alloc] initWithRootViewController:[YBPlayerListViewController new]];
    [_window makeKeyAndVisible];
    
    return YES;
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

@end
