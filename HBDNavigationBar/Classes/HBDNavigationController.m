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
@property (nonatomic, strong) UIVisualEffectView *fromFakeBar;
@property (nonatomic, strong) UIVisualEffectView *toFakeBar;

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
    [self.navigationBar setShadowImage:[UINavigationBar appearance].shadowImage];
    [self.navigationBar setTranslucent:YES]; // make sure translucent
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
        UIViewController *from = [coordinator viewControllerForKey:UITransitionContextFromViewControllerKey];
        UIViewController *to = [coordinator viewControllerForKey:UITransitionContextToViewControllerKey];
        [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            if (to == viewController && ![from.hbd_barTintColor isEqual:to.hbd_barTintColor]) {
                [self updateNavigationBarShadowImageAlphaForViewController:to];
                [UIView setAnimationsEnabled:NO];
                self.navigationBar.fakeView.alpha = 0;
                
                self.fromFakeBar.subviews[1].backgroundColor = from.hbd_barTintColor;
                self.fromFakeBar.alpha = from.hbd_barAlpha;
                self.fromFakeBar.frame = [self fakeBarFrameForViewController:from];
                [from.view addSubview:self.fromFakeBar];
                
                self.toFakeBar.subviews[1].backgroundColor = to.hbd_barTintColor;
                self.toFakeBar.alpha = to.hbd_barAlpha;
                CGRect frame = [self fakeBarFrameForViewController:to];
                frame.origin.y = self.fromFakeBar.frame.origin.y;
                self.toFakeBar.frame = frame;
                [to.view addSubview:self.toFakeBar];
                
                [UIView setAnimationsEnabled:YES];
            } else {
                [self updateNavigationBarForController:viewController];
            }
        } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            if (context.isCancelled) {
                [self updateNavigationBarForController:from];
            } else {
                // 当 present 时 to 不等于 viewController
                [self updateNavigationBarForController:viewController];
            }
            if (to == viewController) {
                [self.fromFakeBar removeFromSuperview];
                [self.toFakeBar removeFromSuperview];
                self.fromFakeBar = nil;
                self.toFakeBar = nil;
            }
        }];
    } else {
        [self updateNavigationBarForController:viewController];
    }
}

- (UIVisualEffectView *)fromFakeBar {
    if (!_fromFakeBar) {
        _fromFakeBar = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    }
    return _fromFakeBar;
}

- (UIVisualEffectView *)toFakeBar {
    if (!_toFakeBar) {
        _toFakeBar = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    }
    return _toFakeBar;
}

- (CGRect)fakeBarFrameForViewController:(UIViewController *)vc {
    CGRect frame = [self.navigationBar.fakeView convertRect:self.navigationBar.fakeView.frame toView:vc.view];
    frame.origin.x = vc.view.frame.origin.x;
    return frame;
}

- (void)updateNavigationBarForController:(UIViewController *)vc {
    [self updateNavigationBarAlphaForViewController:vc];
    [self updateNavigationBarColorForViewController:vc];
    [self updateNavigationBarShadowImageAlphaForViewController:vc];
}

- (void)updateNavigationBarAlphaForViewController:(UIViewController *)vc {
    self.navigationBar.fakeView.alpha = vc.hbd_barAlpha;
    self.navigationBar.shadowImageView.alpha = vc.hbd_barShadowAlpha;
}

- (void)updateNavigationBarColorForViewController:(UIViewController *)vc {
    self.navigationBar.barTintColor = vc.hbd_barTintColor;
}

- (void)updateNavigationBarShadowImageAlphaForViewController:(UIViewController *)vc {
    self.navigationBar.shadowImageView.alpha = vc.hbd_barShadowAlpha;
}

@end

