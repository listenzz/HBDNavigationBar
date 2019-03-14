//
//  HBDNavigationController.m
//  HBDNavigationBar
//
//  Created by Listen on 2018/3/23.
//

#import "HBDNavigationController.h"
#import "UIViewController+HBD.h"
#import "HBDNavigationBar.h"

@interface HBDGestureRecognizerDelegate : NSObject <UIGestureRecognizerDelegate>

@property (nonatomic, weak) HBDNavigationController *navigationController;

- (instancetype)initWithNavigationController:(HBDNavigationController *)navigationController;

@end

@implementation HBDGestureRecognizerDelegate

- (instancetype)initWithNavigationController:(HBDNavigationController *)navigationController {
    if (self = [super init]) {
        self.navigationController = navigationController;
    }
    return self;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (self.navigationController.viewControllers.count > 1) {
        return self.navigationController.topViewController.hbd_backInteractive && self.navigationController.topViewController.hbd_swipeBackEnabled;
    }
    return NO;
}

@end

@interface HBDNavigationController () <UINavigationControllerDelegate>

@property (nonatomic, readonly) HBDNavigationBar *navigationBar;
@property (nonatomic, strong) UIVisualEffectView *fromFakeBar;
@property (nonatomic, strong) UIVisualEffectView *toFakeBar;
@property (nonatomic, strong) UIImageView *fromFakeShadow;
@property (nonatomic, strong) UIImageView *toFakeShadow;
@property (nonatomic, strong) UIImageView *fromFakeImageView;
@property (nonatomic, strong) UIImageView *toFakeImageView;
@property (nonatomic, weak) UIViewController *poppingViewController;
@property (nonatomic, assign) BOOL transitional;
@property (nonatomic, strong) HBDGestureRecognizerDelegate *gestureRecognizerDelegate;

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

- (UIViewController *)childViewControllerForStatusBarHidden {
    return self.topViewController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.gestureRecognizerDelegate = [[HBDGestureRecognizerDelegate alloc] initWithNavigationController:self];
    self.interactivePopGestureRecognizer.delegate = self.gestureRecognizerDelegate;
    [self.interactivePopGestureRecognizer addTarget:self action:@selector(handlePopGesture:)];
    self.delegate = self;
    [self.navigationBar setTranslucent:YES];
    [self.navigationBar setShadowImage:[UINavigationBar appearance].shadowImage];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    // https://github.com/listenzz/HBDNavigationBar/issues/29
    self.topViewController.view.frame = self.topViewController.view.frame;
    
    id<UIViewControllerTransitionCoordinator> coordinator = self.transitionCoordinator;
    if (coordinator) {
        // Fix the issue that the button bounces when the back gesture is released @iOS 11
        UIViewController *from = [coordinator viewControllerForKey:UITransitionContextFromViewControllerKey];
        if (from == self.poppingViewController && !self.transitional) {
            [self updateNavigationBarForViewController:from];
        }
    } else {
        // https://github.com/listenzz/HBDNavigationBar/issues/31
        [self updateNavigationBarForViewController:self.topViewController];
    }
}
- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
    if (self.viewControllers.count > 1 && self.topViewController.navigationItem == item ) {
        if (!(self.topViewController.hbd_backInteractive && self.topViewController.hbd_clickBackEnabled)) {
            [self resetSubviewsInNavBar:self.navigationBar];
            return NO;
        }
    }
    return [super navigationBar:navigationBar shouldPopItem:item];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    self.transitional = YES;
    self.navigationBar.titleTextAttributes = viewController.hbd_titleTextAttributes;
    self.navigationBar.barStyle = viewController.hbd_barStyle;
    
    id<UIViewControllerTransitionCoordinator> coordinator = self.transitionCoordinator;
    if (coordinator) {
        [self showViewController:viewController withCoordinator:coordinator];
    } else {
        if (!animated && self.childViewControllers.count > 1) {
            UIViewController *lastButOne = self.childViewControllers[self.childViewControllers.count - 2];
            if (shouldShowFake(viewController, lastButOne, viewController)) {
                [self showFakeBarFrom:lastButOne to:viewController];
                return;
            }
        }
        [self updateNavigationBarForViewController:viewController];
    }
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    self.transitional = NO;
    if (!animated) {
        [self updateNavigationBarForViewController:viewController];
        [self clearFake];
    }
    self.poppingViewController = nil;
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    self.poppingViewController = self.topViewController;
    UIViewController *vc = [super popViewControllerAnimated:animated];
    // vc != self.topViewController
    // fix：ios 11 and above，当前后两个页面的 barStyle 不一样时，点击返回按钮返回，前一个页面的标题颜色响应迟缓或不响应
    self.navigationBar.barStyle = self.topViewController.hbd_barStyle;
    self.navigationBar.titleTextAttributes = self.topViewController.hbd_titleTextAttributes;
    return vc;
}

- (NSArray<UIViewController *> *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    self.poppingViewController = self.topViewController;
    NSArray *array = [super popToViewController:viewController animated:animated];
    self.navigationBar.barStyle = self.topViewController.hbd_barStyle;
    self.navigationBar.titleTextAttributes = self.topViewController.hbd_titleTextAttributes;
    return array;
}

- (NSArray<UIViewController *> *)popToRootViewControllerAnimated:(BOOL)animated {
    self.poppingViewController = self.topViewController;
    NSArray *array = [super popToRootViewControllerAnimated:animated];
    self.navigationBar.barStyle = self.topViewController.hbd_barStyle;
    self.navigationBar.titleTextAttributes = self.topViewController.hbd_titleTextAttributes;
    return array;
}

- (void)handlePopGesture:(UIScreenEdgePanGestureRecognizer *)recognizer {
    id<UIViewControllerTransitionCoordinator> coordinator = self.transitionCoordinator;
    UIViewController *from = [coordinator viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *to = [coordinator viewControllerForKey:UITransitionContextToViewControllerKey];
    if (recognizer.state == UIGestureRecognizerStateBegan || recognizer.state == UIGestureRecognizerStateChanged) {
        self.navigationBar.tintColor = blendColor(from.hbd_tintColor, to.hbd_tintColor, coordinator.percentComplete);
    }
}

- (void)resetSubviewsInNavBar:(UINavigationBar *)navBar {
    if (@available(iOS 11, *)) {
    } else {
        // Workaround for >= iOS7.1. Thanks to @boliva - http://stackoverflow.com/posts/comments/34452906
        [navBar.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull subview, NSUInteger idx, BOOL * _Nonnull stop) {
            if (subview.alpha < 1.0) {
                [UIView animateWithDuration:.25 animations:^{
                    subview.alpha = 1.0;
                }];
            }
        }];
    }
}

- (void)resetButtonLabelInNavBar:(UINavigationBar *)navBar {
    if (@available(iOS 12.0, *)) {
        for (UIView *view in navBar.subviews) {
            NSString *viewName = [[[view classForCoder] description] stringByReplacingOccurrencesOfString:@"_" withString:@""];
            if ([viewName isEqualToString:@"UINavigationBarContentView"]) {
                [self resetButtonLabelInView:view];
                break;
            }
        }
    }
}

- (void)resetButtonLabelInView:(UIView *)view {
    NSString *viewName = [[[view classForCoder] description] stringByReplacingOccurrencesOfString:@"_" withString:@""];
    if ([viewName isEqualToString:@"UIButtonLabel"]) {
        view.alpha = 1.0;
    } else if (view.subviews.count > 0) {
        for (UIView *sub in view.subviews) {
            [self resetButtonLabelInView:sub];
        }
    }
}

- (void)printSubViews:(UIView *)view prefix:(NSString *)prefix {
    NSString *viewName = [[[view classForCoder] description] stringByReplacingOccurrencesOfString:@"_" withString:@""];
    NSLog(@"%@%@", prefix, viewName);
    if (view.subviews.count > 0) {
        for (UIView *sub in view.subviews) {
            [self printSubViews:sub prefix:[NSString stringWithFormat:@"--%@", prefix]];
        }
    }
}

- (void)updateNavigationBarForViewController:(UIViewController *)vc {
    [self updateNavigationBarAlphaForViewController:vc];
    [self updateNavigationBarColorOrImageForViewController:vc];
    [self updateNavigationBarShadowImageIAlphaForViewController:vc];
    [self updateNavigationBarAnimatedForViewController:vc];
}

- (void)updateNavigationBarAnimatedForViewController:(UIViewController *)vc {
    [UIView setAnimationsEnabled:NO];
    self.navigationBar.barStyle = vc.hbd_barStyle;
    self.navigationBar.titleTextAttributes = vc.hbd_titleTextAttributes;
    self.navigationBar.tintColor = vc.hbd_tintColor;
    [UIView setAnimationsEnabled:YES];
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

- (void)updateNavigationBarColorOrImageForViewController:(UIViewController *)vc {
    self.navigationBar.barTintColor = vc.hbd_computedBarTintColor;
    self.navigationBar.backgroundImageView.image = vc.hbd_computedBarImage;
}

- (void)updateNavigationBarShadowImageIAlphaForViewController:(UIViewController *)vc {
    self.navigationBar.shadowImageView.alpha = vc.hbd_computedBarShadowAlpha;
}

- (void)showViewController:(UIViewController * _Nonnull)viewController withCoordinator: (id<UIViewControllerTransitionCoordinator>)coordinator{
    UIViewController *from = [coordinator viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *to = [coordinator viewControllerForKey:UITransitionContextToViewControllerKey];
    
    // Fix a system bug https://github.com/listenzz/HBDNavigationBar/issues/35
    [self resetButtonLabelInNavBar:self.navigationBar];
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
        BOOL shouldFake = shouldShowFake(viewController, from, to);
        if (shouldFake) {
            [self showViewControllerAlongsideTransition:viewController from:from to:to interactive:context.interactive];
        } else {
            [self showViewControllerAlongsideTransition:viewController interactive:context.interactive];
        }
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
        self.transitional = NO;
        if (context.isCancelled) {
            [self updateNavigationBarForViewController:from];
        } else {
            // `to` != `viewController` when present
            [self updateNavigationBarForViewController:viewController];
        }
        if (to == viewController) {
            [self clearFake];
        }
    }];
    
    if (coordinator.interactive) {
        if (@available(iOS 10.0, *)) {
            [coordinator notifyWhenInteractionChangesUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
                if (context.isCancelled) {
                    [self updateNavigationBarAnimatedForViewController:from];
                } else {
                    [self updateNavigationBarAnimatedForViewController:viewController];
                }
            }];
        } else {
            [coordinator notifyWhenInteractionEndsUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
                if (context.isCancelled) {
                    [self updateNavigationBarAnimatedForViewController:from];
                } else {
                    [self updateNavigationBarAnimatedForViewController:viewController];
                }
            }];
        }
    }
}

- (void)showViewControllerAlongsideTransition:(UIViewController * _Nonnull)viewController interactive:(BOOL)interactive {
    self.navigationBar.titleTextAttributes = viewController.hbd_titleTextAttributes;
    self.navigationBar.barStyle = viewController.hbd_barStyle;
    if (!interactive) {
        self.navigationBar.tintColor = viewController.hbd_tintColor;
    }
    
    [self updateNavigationBarAlphaForViewController:viewController];
    [self updateNavigationBarColorOrImageForViewController:viewController];
    [self updateNavigationBarShadowImageIAlphaForViewController:viewController];
}

- (void)showViewControllerAlongsideTransition:(UIViewController *)viewController from:(UIViewController *)from to:(UIViewController * _Nonnull)to interactive:(BOOL)interactive {
    // title attributes, button tint colo, barStyle
    self.navigationBar.titleTextAttributes = viewController.hbd_titleTextAttributes;
    self.navigationBar.barStyle = viewController.hbd_barStyle;
    if (!interactive) {
        self.navigationBar.tintColor = viewController.hbd_tintColor;
    }
    // background alpha, background color, shadow image alpha
    [self showFakeBarFrom:from to:to];
}

- (void)showFakeBarFrom:(UIViewController *)from to:(UIViewController * _Nonnull)to {
    [UIView setAnimationsEnabled:NO];
    self.navigationBar.fakeView.alpha = 0;
    self.navigationBar.shadowImageView.alpha = 0;
    self.navigationBar.backgroundImageView.alpha = 0;
    [self showFakeBarFrom:from];
    [self showFakeBarTo:to];
    [UIView setAnimationsEnabled:YES];
}

- (void)showFakeBarFrom:(UIViewController *)from {
    self.fromFakeImageView.image = from.hbd_computedBarImage;
    self.fromFakeImageView.alpha = from.hbd_barAlpha;
    self.fromFakeImageView.frame = [self fakeBarFrameForViewController:from];
    [from.view addSubview:self.fromFakeImageView];
    
    self.fromFakeBar.subviews.lastObject.backgroundColor = from.hbd_computedBarTintColor;
    self.fromFakeBar.alpha = from.hbd_barAlpha == 0 || from.hbd_computedBarImage ? 0.01:from.hbd_barAlpha;
    if (from.hbd_barAlpha == 0 || from.hbd_computedBarImage) {
        self.fromFakeBar.subviews.lastObject.alpha = 0.01;
    }
    self.fromFakeBar.frame = [self fakeBarFrameForViewController:from];
    [from.view addSubview:self.fromFakeBar];
    
    self.fromFakeShadow.alpha = from.hbd_computedBarShadowAlpha;
    self.fromFakeShadow.frame = [self fakeShadowFrameWithBarFrame:self.fromFakeBar.frame];
    [from.view addSubview:self.fromFakeShadow];
}

- (void)showFakeBarTo:(UIViewController * _Nonnull)to {
    self.toFakeImageView.image = to.hbd_computedBarImage;
    self.toFakeImageView.alpha = to.hbd_barAlpha;
    self.toFakeImageView.frame = [self fakeBarFrameForViewController:to];
    [to.view addSubview:self.toFakeImageView];
    
    self.toFakeBar.subviews.lastObject.backgroundColor = to.hbd_computedBarTintColor;
    self.toFakeBar.alpha = to.hbd_computedBarImage ? 0 : to.hbd_barAlpha;
    self.toFakeBar.frame = [self fakeBarFrameForViewController:to];
    [to.view addSubview:self.toFakeBar];
    
    self.toFakeShadow.alpha = to.hbd_computedBarShadowAlpha;
    self.toFakeShadow.frame = [self fakeShadowFrameWithBarFrame:self.toFakeBar.frame];
    [to.view addSubview:self.toFakeShadow];
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
    [_fromFakeBar removeFromSuperview];
    [_toFakeBar removeFromSuperview];
    [_fromFakeShadow removeFromSuperview];
    [_toFakeShadow removeFromSuperview];
    [_fromFakeImageView removeFromSuperview];
    [_toFakeImageView removeFromSuperview];
    _fromFakeBar = nil;
    _toFakeBar = nil;
    _fromFakeShadow = nil;
    _toFakeShadow = nil;
    _fromFakeImageView = nil;
    _toFakeImageView = nil;
}

- (CGRect)fakeBarFrameForViewController:(UIViewController *)vc {
    UIView *back = self.navigationBar.subviews[0];
    CGRect frame = [self.navigationBar convertRect:back.frame toView:vc.view];
    frame.origin.x = vc.view.frame.origin.x;
    // fix issue for pushed to UIViewController whose root view is UIScrollView.
    if ([vc.view isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scrollview = (UIScrollView *)vc.view;
        // Adapt iPhoneX iPhoneXR
        NSArray *xrs =@[ @812, @896 ];
        BOOL isIPhoneX = [xrs containsObject:@([UIScreen mainScreen].bounds.size.height)];
        if (scrollview.contentOffset.y == 0) {
            frame.origin.y = -(isIPhoneX ? 88 : 64);
        }
    }
    return frame;
}

- (CGRect)fakeShadowFrameWithBarFrame:(CGRect)frame {
    return CGRectMake(frame.origin.x, frame.size.height + frame.origin.y - 0.5, frame.size.width, 0.5);
}

BOOL shouldShowFake(UIViewController *vc,UIViewController *from, UIViewController *to) {
    if (vc != to ) {
        return NO;
    }
    
    if (from.hbd_computedBarImage && to.hbd_computedBarImage && isImageEqual(from.hbd_computedBarImage, to.hbd_computedBarImage)) {
        // have the same image
        if (ABS(from.hbd_barAlpha - to.hbd_barAlpha) > 0.1) {
            return YES;
        }
        return NO;
    }
    
    if (!from.hbd_computedBarImage && !to.hbd_computedBarImage && [from.hbd_computedBarTintColor.description isEqual:to.hbd_computedBarTintColor.description]) {
        // no images, and the colors are the same
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

UIColor* blendColor(UIColor *from, UIColor *to, float percent) {
    CGFloat fromRed = 0;
    CGFloat fromGreen = 0;
    CGFloat fromBlue = 0;
    CGFloat fromAlpha = 0;
    [from getRed:&fromRed green:&fromGreen blue:&fromBlue alpha:&fromAlpha];
    
    CGFloat toRed = 0;
    CGFloat toGreen = 0;
    CGFloat toBlue = 0;
    CGFloat toAlpha = 0;
    [to getRed:&toRed green:&toGreen blue:&toBlue alpha:&toAlpha];
    
    CGFloat newRed =  fromRed + (toRed - fromRed) * fminf(1, percent * 4) ;
    CGFloat newGreen = fromGreen + (toGreen - fromGreen) * fminf(1, percent * 4);
    CGFloat newBlue = fromBlue + (toBlue - fromBlue) * fminf(1, percent * 4);
    CGFloat newAlpha = fromAlpha + (toAlpha - fromAlpha) * fminf(1, percent * 4);
    return [UIColor colorWithRed:newRed green:newGreen blue:newBlue alpha:newAlpha];
}

@end

