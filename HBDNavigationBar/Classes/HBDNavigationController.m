//
//  HBDNavigationController.m
//  HBDNavigationBar
//
//  Created by Listen on 2018/3/23.
//

#import "HBDNavigationController.h"
#import "UIViewController+HBD.h"
#import "HBDNavigationBar.h"

@interface HBDNavigationController () <UIGestureRecognizerDelegate, UINavigationControllerDelegate>

@property (nonatomic, readonly) HBDNavigationBar *navigationBar;

@end

@implementation HBDNavigationController

@dynamic navigationBar;

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    if (self = [super initWithNavigationBarClass:[HBDNavigationBar class] toolbarClass:nil]) {
        self.viewControllers = @[ rootViewController ];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.interactivePopGestureRecognizer.delegate = self;
    self.delegate = self;
    [self.navigationBar setBarTintColor:self.topViewController.hbd_barTintColor];
    [self.navigationBar setShadowImage:[UINavigationBar appearance].shadowImage];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (self.viewControllers.count > 1) {
        return self.topViewController.hbd_backInteractive;
    }
    return NO;
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    id<UIViewControllerTransitionCoordinator> coordinator = self.transitionCoordinator;
    if (coordinator) {
        [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            [self updateNavigationBarForController:viewController];
        } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            UIViewController *from = [coordinator viewControllerForKey:UITransitionContextFromViewControllerKey];
            UIViewController *to = [coordinator viewControllerForKey:UITransitionContextToViewControllerKey];
            if (context.isCancelled) {
                [self updateNavigationBarForController:from];
            } else {
                [self updateNavigationBarForController:to];
            }
        }];
    }
}

- (void)updateNavigationBarForController:(UIViewController *)vc {
    [self updateNavigationBarAlphaForViewController:vc];
    [self updateNavigationBarColorForViewController:vc];
    [self updateNavigationBarShadowImageAlphaForViewController:vc];
}

- (void)updateNavigationBarAlphaForViewController:(UIViewController *)vc {
    self.navigationBar.alphaView.alpha = vc.hbd_barAlpha;
    self.navigationBar.shadowImageView.alpha = vc.hbd_barShadowAlpha;
}

- (void)updateNavigationBarColorForViewController:(UIViewController *)vc {
    self.navigationBar.barTintColor = vc.hbd_barTintColor;
}

- (void)updateNavigationBarShadowImageAlphaForViewController:(UIViewController *)vc {
    self.navigationBar.shadowImageView.alpha = vc.hbd_barShadowAlpha;
}

@end

