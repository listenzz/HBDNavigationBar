//
//  HBDAppDelegate.m
//  HBDNavigationBar
//
//  Created by listenzz@163.com on 03/23/2018.
//  Copyright (c) 2018 listenzz@163.com. All rights reserved.
//

#import "HBDAppDelegate.h"
#import <HBDNavigationBar/HBDNavigationController.h>
#import "UIImage+Help.h"
#import "UIColor+Help.h"

@implementation HBDAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

   [[UINavigationBar appearance] setBarTintColor:[UIColor.whiteColor colorWithAlphaComponent:.8]];
   // [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
   // [[UINavigationBar appearance] setBackgroundImage:[UIImage imageWithColor:UIColor.blackColor] forBarMetrics:UIBarMetricsDefault];

    return YES;
}

@end
