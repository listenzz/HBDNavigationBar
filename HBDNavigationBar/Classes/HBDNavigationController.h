//
//  HBDNavigationController.h
//  HBDNavigationBar
//
//  Created by Listen on 2018/3/23.
//

#import <UIKit/UIKit.h>

@interface HBDNavigationController : UINavigationController

- (void)updateNavigationBarForController:(UIViewController *)vc;
- (void)updateNavigationBarAlphaForViewController:(UIViewController *)vc;
- (void)updateNavigationBarColorForViewController:(UIViewController *)vc;
- (void)updateNavigationBarShadowImageAlphaForViewController:(UIViewController *)vc;

@end
