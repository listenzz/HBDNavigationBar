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
@property (nonatomic, strong) UIImageView *fromFakeShadow;
@property (nonatomic, strong) UIImageView *toFakeShadow;
@property (nonatomic, strong) UIImageView *fromFakeImageView;
@property (nonatomic, strong) UIImageView *toFakeImageView;

@end

@implementation HBDNavigationController

@dynamic navigationBar;

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    if (self = [super initWithNavigationBarClass:[HBDNavigationBar class] toolbarClass:nil]) {
        self.viewControllers = @[ rootViewController ];
    }
    return self;
}

- (instancetype)initWithNavigationBarClass:(Class)navigationBarClass toolbarClass:(Class)toolbarClass {
    NSAssert([navigationBarClass isSubclassOfClass:[HBDNavigationBar class]], @"navigationBarClass Must be a subclass of HBDNavigationBar");
    return [super initWithNavigationBarClass:navigationBarClass toolbarClass:toolbarClass];
}

- (instancetype)init {
    return [super initWithNavigationBarClass:[HBDNavigationBar class] toolbarClass:nil];
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
    self.navigationBar.barStyle = viewController.hbd_barStyle;
    id<UIViewControllerTransitionCoordinator> coordinator = self.transitionCoordinator;
    if (coordinator) {
        UIViewController *from = [coordinator viewControllerForKey:UITransitionContextFromViewControllerKey];
        UIViewController *to = [coordinator viewControllerForKey:UITransitionContextToViewControllerKey];
        [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            if (shouldShowFake(viewController, from, to)) {
                [UIView performWithoutAnimation:^{
                    self.navigationBar.fakeView.alpha = 0;
                    self.navigationBar.shadowImageView.alpha = 0;
                    self.navigationBar.backgroundImageView.alpha = 0;
                    
                    // from
                    self.fromFakeImageView.image = from.hbd_computedBarImage;
                    self.fromFakeImageView.alpha = from.hbd_barAlpha;
                    self.fromFakeImageView.frame = [self fakeBarFrameForViewController:from];
                    [from.view addSubview:self.fromFakeImageView];
                    self.fromFakeBar.subviews[1].backgroundColor = from.hbd_computedBarTintColor;
                    self.fromFakeBar.alpha = from.hbd_barAlpha == 0 || from.hbd_computedBarImage ? 0.01:from.hbd_barAlpha;
                    if (from.hbd_barAlpha == 0 || from.hbd_computedBarImage) {
                        self.fromFakeBar.subviews[1].alpha = 0.01;
                    }
                    self.fromFakeBar.frame = [self fakeBarFrameForViewController:from];
                    [from.view addSubview:self.fromFakeBar];
               
                    self.fromFakeShadow.alpha = from.hbd_computedBarShadowAlpha;
                    self.fromFakeShadow.frame = [self fakeShadowFrameWithBarFrame:self.fromFakeBar.frame];
                    [from.view addSubview:self.fromFakeShadow];
                    
                    // to
                    self.toFakeImageView.image = to.hbd_computedBarImage;
                    self.toFakeImageView.alpha = to.hbd_barAlpha;
                    self.toFakeImageView.frame = [self fakeBarFrameForViewController:to];
                    [to.view addSubview:self.toFakeImageView];
                    self.toFakeBar.subviews[1].backgroundColor = to.hbd_computedBarTintColor;
                    self.toFakeBar.alpha = to.hbd_computedBarImage ? 0 : to.hbd_barAlpha;
                    self.toFakeBar.frame = [self fakeBarFrameForViewController:to];
                    [to.view addSubview:self.toFakeBar];
                    self.toFakeShadow.alpha = to.hbd_computedBarShadowAlpha;
                    self.toFakeShadow.frame = [self fakeShadowFrameWithBarFrame:self.toFakeBar.frame];
                    [to.view addSubview:self.toFakeShadow];
                }];
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
                [self clearFake];
            }
        }];
    } else {
        [self updateNavigationBarForController:viewController];
    }
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    UIViewController *vc = [super popViewControllerAnimated:animated];
    self.navigationBar.barStyle = self.topViewController.hbd_barStyle;
    return vc;
}

- (NSArray<UIViewController *> *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    NSArray *array = [super popToViewController:viewController animated:animated];
    self.navigationBar.barStyle = self.topViewController.hbd_barStyle;
    return array;
}

- (NSArray<UIViewController *> *)popToRootViewControllerAnimated:(BOOL)animated {
    NSArray *array = [super popToRootViewControllerAnimated:animated];
    self.navigationBar.barStyle = self.topViewController.hbd_barStyle;
    return array;
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

- (UIImageView *)fromFakeImageView {
    if (!_fromFakeImageView) {
        _fromFakeImageView = [[UIImageView alloc] init];
    }
    return _fromFakeImageView;
}

- (UIImageView *)toFakeImageView {
    if (!_toFakeImageView) {
        _toFakeImageView = [[UIImageView alloc] init];
    }
    return _toFakeImageView;
}

- (UIImageView *)fromFakeShadow {
    if (!_fromFakeShadow) {
        _fromFakeShadow = [[UIImageView alloc] initWithImage:self.navigationBar.shadowImageView.image];
        _fromFakeShadow.backgroundColor = self.navigationBar.shadowImageView.backgroundColor;
    }
    return _fromFakeShadow;
}

- (UIImageView *)toFakeShadow {
    if (!_toFakeShadow) {
        _toFakeShadow = [[UIImageView alloc] initWithImage:self.navigationBar.shadowImageView.image];
        _toFakeShadow.backgroundColor = self.navigationBar.shadowImageView.backgroundColor;
    }
    return _toFakeShadow;
}

- (void)clearFake {
    [self.fromFakeBar removeFromSuperview];
    [self.toFakeBar removeFromSuperview];
    [self.fromFakeShadow removeFromSuperview];
    [self.toFakeShadow removeFromSuperview];
    [self.fromFakeImageView removeFromSuperview];
    [self.toFakeImageView removeFromSuperview];
    self.fromFakeBar = nil;
    self.toFakeBar = nil;
    self.fromFakeShadow = nil;
    self.toFakeShadow = nil;
    self.fromFakeImageView = nil;
    self.toFakeImageView = nil;
}

BOOL shouldShowFake(UIViewController *vc,UIViewController *from, UIViewController *to) {
    if (vc != to ) {
        return NO;
    }
    
    if (from.hbd_computedBarImage && to.hbd_computedBarImage && isImageEqual(from.hbd_computedBarImage, to.hbd_computedBarImage)) {
        // 都有图片，并且是同一张图片
        if (ABS(from.hbd_barAlpha - to.hbd_barAlpha) > 0.1) {
            return YES;
        }
        return NO;
    }
    
    if (!from.hbd_computedBarImage && !to.hbd_computedBarImage && [from.hbd_computedBarTintColor.description isEqual:to.hbd_computedBarTintColor.description]) {
        // 都没图片，并且颜色相同
        if (ABS(from.hbd_barAlpha - to.hbd_barAlpha) > 0.1) {
            return YES;
        }
        return NO;
    }
    
    return YES;
}

BOOL isImageEqual(UIImage *image1, UIImage *image2) {
    if (image1 == image2) {
        return YES;
    }
    if (image1 && image2) {
        NSData *data1 = UIImagePNGRepresentation(image1);
        NSData *data2 = UIImagePNGRepresentation(image2);
        BOOL result = [data1 isEqual:data2];
        return result;
    }
    return NO;
}

- (CGRect)fakeBarFrameForViewController:(UIViewController *)vc {
    UIView *back = self.navigationBar.subviews[0];
    CGRect frame = [self.navigationBar convertRect:back.frame toView:vc.view];
    frame.origin.x = vc.view.frame.origin.x;
    return frame;
}

- (CGRect)fakeShadowFrameWithBarFrame:(CGRect)frame {
    return CGRectMake(frame.origin.x, frame.size.height + frame.origin.y, frame.size.width, 0.5);
}

- (void)updateNavigationBarForController:(UIViewController *)vc {
    [self updateNavigationBarAlphaForViewController:vc];
    [self updateNavigationBarColorForViewController:vc];
    [self updateNavigationBarShadowImageAlphaForViewController:vc];
    self.navigationBar.barStyle = vc.hbd_barStyle;
}

- (void)updateNavigationBarAlphaForViewController:(UIViewController *)vc {
    if (vc.hbd_computedBarImage) {
        self.navigationBar.fakeView.alpha = 0;
        self.navigationBar.backgroundImageView.alpha = vc.hbd_barAlpha;
    } else {
        self.navigationBar.fakeView.alpha = vc.hbd_barAlpha;
        self.navigationBar.backgroundImageView.alpha = 0;
    }
    self.navigationBar.shadowImageView.alpha = vc.hbd_computedBarShadowAlpha;
}

- (void)updateNavigationBarColorForViewController:(UIViewController *)vc {
    self.navigationBar.barTintColor = vc.hbd_computedBarTintColor;
    self.navigationBar.backgroundImageView.image = vc.hbd_computedBarImage;
}

- (void)updateNavigationBarShadowImageAlphaForViewController:(UIViewController *)vc {
    self.navigationBar.shadowImageView.alpha = vc.hbd_computedBarShadowAlpha;
}

@end

