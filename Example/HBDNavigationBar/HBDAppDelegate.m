//
//  HBDAppDelegate.m
//  HBDNavigationBar
//
//  Created by listenzz@163.com on 03/23/2018.
//  Copyright (c) 2018 listenzz@163.com. All rights reserved.
//

#import "HBDAppDelegate.h"
#import <HBDNavigationBar/HBDNavigationController.h>

@implementation HBDAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window.backgroundColor = UIColor.blackColor;
    // [[UINavigationBar appearance] setBarTintColor:UIColor.redColor];
    [[UINavigationBar appearance] setTintColor:UIColor.blackColor];
    //[[UINavigationBar appearance] setBackgroundImage:[HBDAppDelegate imageWithColor:UIColor.blueColor] forBarMetrics:UIBarMetricsDefault];
     //   [UIBarButtonItem appearance].tintColor = UIColor.redColor;
    
    return YES;
}

+ (UIImage*)imageWithColor:(UIColor*)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 8.0f, 8.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage*theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

@end
