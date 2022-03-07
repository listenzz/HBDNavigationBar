//
//  HBDNavigationController.h
//  HBDNavigationBar
//
//  Created by Listen on 2018/3/23.
//

#import <UIKit/UIKit.h>

@interface HBDNavigationController : UINavigationController

- (void)updateNavigationBarForViewController:(UIViewController *)vc;

@end

@interface UINavigationController (UINavigationBar) <UINavigationBarDelegate>

@end

@protocol HBDNavigationTransitionProtocol <NSObject>

- (void)handleNavigationTransition:(UIScreenEdgePanGestureRecognizer *)pan;

@end
