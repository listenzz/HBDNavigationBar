//
//  HBDNavigationController.m
//  HBDNavigationBar
//
//  Created by Listen on 2018/3/23.
//

#import "HBDNavigationController.h"
#import "UIViewController+HBD.h"
#import "HBDNavigationBar.h"

#define hairlineWidth (1.f/[UIScreen mainScreen].scale)

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

BOOL shouldShowFake(UIViewController *vc, UIViewController *from, UIViewController *to) {
    if (vc != to) {
        return NO;
    }

    if (from.hbd_splitNavigationBarTransition || to.hbd_splitNavigationBarTransition) {
        return YES;
    }

    if (from.hbd_computedBarImage && to.hbd_computedBarImage && isImageEqual(from.hbd_computedBarImage, to.hbd_computedBarImage)) {
        // have the same image
        return from.hbd_barAlpha != to.hbd_barAlpha;
    }

    if (!from.hbd_computedBarImage && !to.hbd_computedBarImage && [from.hbd_computedBarTintColor.description isEqual:to.hbd_computedBarTintColor.description]) {
        // no images and the colors are the same
        return from.hbd_barAlpha != to.hbd_barAlpha;
    }

    return YES;
}

BOOL colorHasAlphaComponent(UIColor *color) {
    if (!color) {
        return YES;
    }
    CGFloat red = 0;
    CGFloat green = 0;
    CGFloat blue = 0;
    CGFloat alpha = 0;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    return alpha < 1.0;
}

BOOL imageHasAlphaChannel(UIImage *image) {
    CGImageAlphaInfo alpha = CGImageGetAlphaInfo(image.CGImage);
    return (alpha == kCGImageAlphaFirst ||
            alpha == kCGImageAlphaLast ||
            alpha == kCGImageAlphaPremultipliedFirst ||
            alpha == kCGImageAlphaPremultipliedLast);
}

void adjustLayout(UIViewController *vc) {
    BOOL isTranslucent = vc.hbd_barHidden || vc.hbd_barAlpha < 1.0;
    if (!isTranslucent) {
        UIImage *image = vc.hbd_computedBarImage;
        if (image) {
            isTranslucent = imageHasAlphaChannel(image);
        } else {
            UIColor *color = vc.hbd_computedBarTintColor;
            isTranslucent = colorHasAlphaComponent(color);
        }
    }

    if (isTranslucent || vc.extendedLayoutIncludesOpaqueBars) {
        vc.edgesForExtendedLayout |= UIRectEdgeTop;
    } else {
        vc.edgesForExtendedLayout &= ~UIRectEdgeTop;
    }

    if (vc.hbd_barHidden) {
        if (@available(iOS 11.0, *)) {
            UIEdgeInsets insets = vc.additionalSafeAreaInsets;
            CGFloat height = vc.navigationController.navigationBar.bounds.size.height;
            vc.additionalSafeAreaInsets = UIEdgeInsetsMake(-height + insets.top, insets.left, insets.bottom, insets.right);
        }
    }
}

UIColor *blendColor(UIColor *from, UIColor *to, CGFloat percent) {
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

    CGFloat newRed = fromRed + (toRed - fromRed) * fminf(1, (float) (percent * 4));
    CGFloat newGreen = fromGreen + (toGreen - fromGreen) * fminf(1, (float) (percent * 4));
    CGFloat newBlue = fromBlue + (toBlue - fromBlue) * fminf(1, (float) (percent * 4));
    CGFloat newAlpha = fromAlpha + (toAlpha - fromAlpha) * fminf(1, (float) (percent * 4));
    return [UIColor colorWithRed:newRed green:newGreen blue:newBlue alpha:newAlpha];
}

void printViewHierarchy(UIView *view, NSString *prefix) {
    NSString *viewName = [[[view classForCoder] description] stringByReplacingOccurrencesOfString:@"_" withString:@""];
    NSLog(@"%@%@ %@", prefix, viewName, NSStringFromCGRect(view.frame));
    if (view.subviews.count > 0) {
        for (UIView *sub in view.subviews) {
            printViewHierarchy(sub, [NSString stringWithFormat:@"--%@", prefix]);
        }
    }
}

@interface HBDNavigationControllerDelegate : UIScreenEdgePanGestureRecognizer <UINavigationControllerDelegate, UIGestureRecognizerDelegate>

@property(nonatomic, weak) id <UINavigationControllerDelegate> navDelegate;
@property(nonatomic, weak, readonly) HBDNavigationController *nav;

- (instancetype)initWithNavigationController:(HBDNavigationController *)navigationController;

@end

@interface HBDNavigationController ()

@property(nonatomic, readonly) HBDNavigationBar *navigationBar;
@property(nonatomic, strong) UIVisualEffectView *fromFakeBar;
@property(nonatomic, strong) UIVisualEffectView *toFakeBar;
@property(nonatomic, strong) UIImageView *fromFakeShadow;
@property(nonatomic, strong) UIImageView *toFakeShadow;
@property(nonatomic, strong) UIImageView *fromFakeImageView;
@property(nonatomic, strong) UIImageView *toFakeImageView;
@property(nonatomic, weak) UIViewController *poppingViewController;
@property(nonatomic, strong) HBDNavigationControllerDelegate *delegateProxy;

- (void)updateNavigationBarStyleForViewController:(UIViewController *)vc;

- (void)updateNavigationBarTintColorForViewController:(UIViewController *)vc;

- (void)updateNavigationBarAlphaForViewController:(UIViewController *)vc;

- (void)updateNavigationBarBackgroundForViewController:(UIViewController *)vc;

- (void)showFakeBarFrom:(UIViewController *)from to:(UIViewController *)to;

- (void)clearFake;

- (void)resetSubviewsInNavBar:(UINavigationBar *)navBar;

- (UIGestureRecognizer *)superInteractivePopGestureRecognizer;

@end

@implementation HBDNavigationControllerDelegate

- (instancetype)initWithNavigationController:(HBDNavigationController *)nav {
    if (self = [super init]) {
        _nav = nav;
        self.edges = UIRectEdgeLeft;
        self.delegate = self;
        [self addTarget:self action:@selector(handleNavigationTransition:)];
        [nav.view addGestureRecognizer:self];
        [nav superInteractivePopGestureRecognizer].enabled = NO;
    }
    return self;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (self.nav.viewControllers.count > 1) {
        // 先判断hbd_swipeBackEnabled再判断hbd_backInteractive，
        // 可以解决当用户已经将hbd_swipeBackEnabled设置为NO时，并且重写了hbd_backInteractive的getter方法，用手势返回时，先调用hbd_backInteractive的getter方法的问题
        // 应该是已经将hbd_swipeBackEnabled设置为NO后，用户再进行侧滑手势时，不触发任何操作。
        return self.nav.topViewController.hbd_swipeBackEnabled && self.nav.topViewController.hbd_backInteractive;
    }
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer API_AVAILABLE(ios(7.0)) {
    if (gestureRecognizer == self.nav.interactivePopGestureRecognizer) {
        return YES;
    }
    return NO;
}

- (void)handleNavigationTransition:(UIScreenEdgePanGestureRecognizer *)pan {
    HBDNavigationController *nav = self.nav;
    if (![self.navDelegate respondsToSelector:@selector(navigationController:interactionControllerForAnimationController:)]) {
        id <HBDNavigationTransitionProtocol> target = (id <HBDNavigationTransitionProtocol>) [nav superInteractivePopGestureRecognizer].delegate;
        if ([target respondsToSelector:@selector(handleNavigationTransition:)]) {
            [target handleNavigationTransition:pan];
        }
    }

    if (@available(iOS 11.0, *)); else return;
    id <UIViewControllerTransitionCoordinator> coordinator = nav.transitionCoordinator;
    if (coordinator) {
        UIViewController *from = [coordinator viewControllerForKey:UITransitionContextFromViewControllerKey];
        UIViewController *to = [coordinator viewControllerForKey:UITransitionContextToViewControllerKey];
        if (pan.state == UIGestureRecognizerStateBegan || pan.state == UIGestureRecognizerStateChanged) {
            nav.navigationBar.tintColor = blendColor(from.hbd_tintColor, to.hbd_tintColor, coordinator.percentComplete);
        }
    }
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.navDelegate && [self.navDelegate respondsToSelector:@selector(navigationController:willShowViewController:animated:)]) {
        [self.navDelegate navigationController:navigationController willShowViewController:viewController animated:animated];
    }

    if (!viewController.hbd_extendedLayoutDidSet) {
        adjustLayout(viewController);
        viewController.hbd_extendedLayoutDidSet = YES;
    }

    HBDNavigationController *nav = self.nav;
    id <UIViewControllerTransitionCoordinator> coordinator = nav.transitionCoordinator;
    if (coordinator) {
        [self showViewController:viewController withCoordinator:coordinator];
    } else {
        if (!animated && nav.childViewControllers.count > 1) {
            UIViewController *lastButOne = nav.childViewControllers[nav.childViewControllers.count - 2];
            if (shouldShowFake(viewController, lastButOne, viewController)) {
                [nav showFakeBarFrom:lastButOne to:viewController];
                return;
            }
        }
        [nav updateNavigationBarForViewController:viewController];
    }
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.navDelegate && [self.navDelegate respondsToSelector:@selector(navigationController:didShowViewController:animated:)]) {
        [self.navDelegate navigationController:navigationController didShowViewController:viewController animated:animated];
    }

    HBDNavigationController *nav = self.nav;
    if (!animated) {
        [nav updateNavigationBarForViewController:viewController];
        [nav clearFake];
    }

    nav.poppingViewController = nil;
}

- (UIInterfaceOrientationMask)navigationControllerSupportedInterfaceOrientations:(UINavigationController *)navigationController {
    if (self.navDelegate && [self.navDelegate respondsToSelector:@selector(navigationControllerSupportedInterfaceOrientations:)]) {
        return [self.navDelegate navigationControllerSupportedInterfaceOrientations:navigationController];
    }
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)navigationControllerPreferredInterfaceOrientationForPresentation:(UINavigationController *)navigationController {
    if (self.navDelegate && [self.navDelegate respondsToSelector:@selector(navigationControllerPreferredInterfaceOrientationForPresentation:)]) {
        return [self.navDelegate navigationControllerPreferredInterfaceOrientationForPresentation:navigationController];
    }
    return UIInterfaceOrientationPortrait;
}

- (nullable id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                                   interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>)animationController {
    if (self.navDelegate && [self.navDelegate respondsToSelector:@selector(navigationController:interactionControllerForAnimationController:)]) {
        return [self.navDelegate navigationController:navigationController interactionControllerForAnimationController:animationController];
    }
    return nil;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                            animationControllerForOperation:(UINavigationControllerOperation)operation
                                                         fromViewController:(UIViewController *)fromVC
                                                           toViewController:(UIViewController *)toVC {
    if (self.navDelegate && [self.navDelegate respondsToSelector:@selector(navigationController:animationControllerForOperation:fromViewController:toViewController:)]) {
        return [self.navDelegate navigationController:navigationController animationControllerForOperation:operation fromViewController:fromVC toViewController:toVC];
    }
    return nil;
}

- (void)showViewController:(UIViewController *_Nonnull)viewController withCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {
    UIViewController *from = [coordinator viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *to = [coordinator viewControllerForKey:UITransitionContextToViewControllerKey];

    if (@available(iOS 12.0, *)) {
        // Fix a system bug https://github.com/listenzz/HBDNavigationBar/issues/35
        [self resetButtonLabelInNavBar:self.nav.navigationBar];
    }

    if (self.nav.poppingViewController) {
        // Inspired by QMUI
        UILabel *backButtonLabel = self.nav.navigationBar.backButtonLabel;
        if (backButtonLabel) {
            backButtonLabel.hbd_specifiedTextColor = backButtonLabel.textColor;
        }

        [coordinator animateAlongsideTransition:^(id <UIViewControllerTransitionCoordinatorContext> _Nonnull context) {

        }                            completion:^(id <UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
            backButtonLabel.hbd_specifiedTextColor = nil;
        }];
    }

    [self.nav updateNavigationBarStyleForViewController:viewController];

    [coordinator animateAlongsideTransition:^(id <UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
        BOOL shouldFake = shouldShowFake(viewController, from, to);
        if (shouldFake) {
            // title attributes, button tint color, barStyle
            [self.nav updateNavigationBarTintColorForViewController:viewController];

            // background alpha, background color, shadow image alpha
            [self.nav showFakeBarFrom:from to:to];
        } else {
            [self.nav updateNavigationBarForViewController:viewController];
            if (@available(iOS 13.0, *)) {
                if (to == viewController) {
                    self.nav.navigationBar.scrollEdgeAppearance.backgroundColor = viewController.hbd_computedBarTintColor;
                    self.nav.navigationBar.scrollEdgeAppearance.backgroundImage = viewController.hbd_computedBarImage;
                    self.nav.navigationBar.standardAppearance.backgroundColor = viewController.hbd_computedBarTintColor;
                    self.nav.navigationBar.standardAppearance.backgroundImage = viewController.hbd_computedBarImage;
                }
            }
        }
    }                            completion:^(id <UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
        self.nav.poppingViewController = nil;
        if (@available(iOS 13.0, *)) {
            self.nav.navigationBar.scrollEdgeAppearance.backgroundColor = UIColor.clearColor;
            self.nav.navigationBar.scrollEdgeAppearance.backgroundImage = nil;
            self.nav.navigationBar.standardAppearance.backgroundColor = UIColor.clearColor;
            self.nav.navigationBar.standardAppearance.backgroundImage = nil;
        }

        if (context.isCancelled) {
            if (to == viewController) {
                [self.nav updateNavigationBarForViewController:from];
            }
        } else {
            // `to` != `viewController` when present
            [self.nav updateNavigationBarForViewController:viewController];
        }
        if (to == viewController) {
            [self.nav clearFake];
        }
    }];
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

@end

@implementation HBDNavigationController

@dynamic navigationBar;

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    if (self = [super initWithNavigationBarClass:[HBDNavigationBar class] toolbarClass:nil]) {
        self.viewControllers = @[rootViewController];
    }
    return self;
}

- (UINavigationController *)initWithNavigationBarClass:(Class)navigationBarClass toolbarClass:(Class)toolbarClass {
    NSAssert([navigationBarClass isSubclassOfClass:[HBDNavigationBar class]], @"navigationBarClass Must be a subclass of HBDNavigationBar");
    return [super initWithNavigationBarClass:navigationBarClass toolbarClass:toolbarClass];
}

- (UINavigationController *)init {
    return [super initWithNavigationBarClass:[HBDNavigationBar class] toolbarClass:nil];
}

- (void)setDelegate:(id <UINavigationControllerDelegate>)delegate {
    if ([delegate isKindOfClass:[HBDNavigationControllerDelegate class]] || !self.delegateProxy) {
        [super setDelegate:delegate];
    } else {
        self.delegateProxy.navDelegate = delegate;
    }
}

- (UIGestureRecognizer *)interactivePopGestureRecognizer {
    return self.delegateProxy;
}

- (UIGestureRecognizer *)superInteractivePopGestureRecognizer {
    return [super interactivePopGestureRecognizer];
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return self.topViewController;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.topViewController.hbd_barStyle == UIBarStyleBlack ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault;
}

- (UIViewController *)childViewControllerForHomeIndicatorAutoHidden {
    return self.topViewController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationBar setTranslucent:YES];
    [self.navigationBar setShadowImage:[UINavigationBar appearance].shadowImage];

    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *scrollEdgeAppearance = [[UINavigationBarAppearance alloc] init];
        [scrollEdgeAppearance configureWithTransparentBackground];
        // scrollEdgeAppearance.backgroundEffect = nil;
        scrollEdgeAppearance.backgroundColor = UIColor.clearColor;
        scrollEdgeAppearance.shadowColor = UIColor.clearColor;
        [scrollEdgeAppearance setBackIndicatorImage:[UINavigationBar appearance].backIndicatorImage transitionMaskImage:[UINavigationBar appearance].backIndicatorTransitionMaskImage];
        self.navigationBar.scrollEdgeAppearance = scrollEdgeAppearance;
        self.navigationBar.standardAppearance = [scrollEdgeAppearance copy];
    }

    self.delegateProxy = [[HBDNavigationControllerDelegate alloc] initWithNavigationController:self];
    self.delegateProxy.navDelegate = self.delegate;
    self.delegate = self.delegateProxy;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    id <UIViewControllerTransitionCoordinator> coordinator = self.transitionCoordinator;
    if (!coordinator) {
        [self updateNavigationBarForViewController:self.topViewController];
    }
}

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
    if (self.viewControllers.count > 1 && self.topViewController.navigationItem == item) {
        if (!(self.topViewController.hbd_backInteractive && self.topViewController.hbd_clickBackEnabled)) {
            [self resetSubviewsInNavBar:self.navigationBar];
            return NO;
        }
    }
    return [super navigationBar:navigationBar shouldPopItem:item];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    self.poppingViewController = self.topViewController;
    UIViewController *vc = [super popViewControllerAnimated:animated];
    // vc != self.topViewController
    [self fixClickBackIssue];
    return vc;
}

- (NSArray<UIViewController *> *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    self.poppingViewController = self.topViewController;
    NSArray *array = [super popToViewController:viewController animated:animated];
    [self fixClickBackIssue];
    return array;
}

- (NSArray<UIViewController *> *)popToRootViewControllerAnimated:(BOOL)animated {
    self.poppingViewController = self.topViewController;
    NSArray *array = [super popToRootViewControllerAnimated:animated];
    [self fixClickBackIssue];
    return array;
}

- (void)fixClickBackIssue {
    if (@available(iOS 13.0, *)) {
        return;
    }
    if (@available(iOS 11.0, *)) {
        // fix：ios 11，12，当前后两个页面的 barStyle 不一样时，点击返回按钮返回，前一个页面的标题颜色响应迟缓或不响应
        id <UIViewControllerTransitionCoordinator> coordinator = self.transitionCoordinator;
        if (!(coordinator && coordinator.interactive)) {
            self.navigationBar.barStyle = self.topViewController.hbd_barStyle;
            self.navigationBar.titleTextAttributes = self.topViewController.hbd_titleTextAttributes;
        }
    }
}

- (void)resetSubviewsInNavBar:(UINavigationBar *)navBar {
    if (@available(iOS 11, *)) {
        // empty
    } else {
        // Workaround for >= iOS7.1. Thanks to @boliva - http://stackoverflow.com/posts/comments/34452906
        [navBar.subviews enumerateObjectsUsingBlock:^(__kindof UIView *_Nonnull subview, NSUInteger idx, BOOL *_Nonnull stop) {
            if (subview.alpha < 1.0) {
                [UIView animateWithDuration:.25 animations:^{
                    subview.alpha = 1.0;
                }];
            }
        }];
    }
}

- (void)updateNavigationBarForViewController:(UIViewController *)vc {
    [self updateNavigationBarStyleForViewController:vc];
    [self updateNavigationBarAlphaForViewController:vc];
    [self updateNavigationBarBackgroundForViewController:vc];
    [self updateNavigationBarTintColorForViewController:vc];
}

- (void)updateNavigationBarStyleForViewController:(UIViewController *)vc {
    self.navigationBar.barStyle = vc.hbd_barStyle;
}

- (void)updateNavigationBarTintColorForViewController:(UIViewController *)vc {
    self.navigationBar.tintColor = vc.hbd_tintColor;
    self.navigationBar.titleTextAttributes = vc.hbd_titleTextAttributes;
    if (@available(iOS 13.0, *)) {
        self.navigationBar.scrollEdgeAppearance.titleTextAttributes = vc.hbd_titleTextAttributes;
        self.navigationBar.standardAppearance.titleTextAttributes = vc.hbd_titleTextAttributes;
    }
}

- (void)updateNavigationBarAlphaForViewController:(UIViewController *)vc {
    if (vc.hbd_computedBarImage) {
        self.navigationBar.fakeView.alpha = 0;
        self.navigationBar.backgroundImageView.alpha = vc.hbd_barAlpha;
    } else {
        self.navigationBar.fakeView.alpha = vc.hbd_barAlpha;
        self.navigationBar.backgroundImageView.alpha = 0;
    }

    if (vc.hbd_barAlpha == 0) {
        self.navigationBar.hbd_backgroundView.layer.mask = [CALayer new];
    } else {
        self.navigationBar.hbd_backgroundView.layer.mask = nil;
    }

    self.navigationBar.shadowImageView.alpha = vc.hbd_computedBarShadowAlpha;
}

- (void)updateNavigationBarBackgroundForViewController:(UIViewController *)vc {
    self.navigationBar.barTintColor = vc.hbd_computedBarTintColor;
    self.navigationBar.backgroundImageView.image = vc.hbd_computedBarImage;
}

- (void)showFakeBarFrom:(UIViewController *)from to:(UIViewController *_Nonnull)to {
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
    self.fromFakeBar.alpha = from.hbd_computedBarImage ? 0 : from.hbd_barAlpha;

    if (from.hbd_barAlpha == 0 || from.hbd_computedBarImage) {
        self.fromFakeBar.subviews.lastObject.layer.mask = [CALayer new];
    }

    self.fromFakeBar.frame = [self fakeBarFrameForViewController:from];
    [from.view addSubview:self.fromFakeBar];

    self.fromFakeShadow.alpha = from.hbd_computedBarShadowAlpha;
    self.fromFakeShadow.frame = [self fakeShadowFrameWithBarFrame:self.fromFakeBar.frame];
    [from.view addSubview:self.fromFakeShadow];
}

- (void)showFakeBarTo:(UIViewController *_Nonnull)to {
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
    CGFloat height = self.navigationBar.frame.size.height + self.navigationBar.frame.origin.y;
    if (vc.view.frame.size.height == self.view.frame.size.height) {
        return CGRectMake(0, 0, self.navigationBar.frame.size.width, height);
    }else{
        return CGRectMake(0, -height, self.navigationBar.frame.size.width, height);
    }
}

- (CGRect)fakeShadowFrameWithBarFrame:(CGRect)frame {
    return CGRectMake(frame.origin.x, frame.size.height + frame.origin.y - hairlineWidth, frame.size.width, hairlineWidth);
}

@end

