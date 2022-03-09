//
//  UIViewController+HBD.m
//  HBDNavigationBar
//
//  Created by Listen on 2018/3/23.
//

#import "UIViewController+HBD.h"
#import <objc/runtime.h>
#import "HBDNavigationController.h"

@implementation UIViewController (HBD)

- (BOOL)hbd_blackBarStyle {
    return self.hbd_barStyle == UIBarStyleBlack;
}

- (void)setHbd_blackBarStyle:(BOOL)hbd_blackBarStyle {
    self.hbd_barStyle = hbd_blackBarStyle ? UIBarStyleBlack : UIBarStyleDefault;
}

- (UIBarStyle)hbd_barStyle {
    id obj = objc_getAssociatedObject(self, _cmd);
    if (obj) {
        return [obj integerValue];
    }
    return [UINavigationBar appearance].barStyle;
}

- (void)setHbd_barStyle:(UIBarStyle)hbd_barStyle {
    objc_setAssociatedObject(self, @selector(hbd_barStyle), @(hbd_barStyle), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (UIColor *)hbd_barTintColor {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setHbd_barTintColor:(UIColor *)tintColor {
    objc_setAssociatedObject(self, @selector(hbd_barTintColor), tintColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImage *)hbd_barImage {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setHbd_barImage:(UIImage *)image {
    objc_setAssociatedObject(self, @selector(hbd_barImage), image, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)hbd_tintColor {
    id obj = objc_getAssociatedObject(self, _cmd);
    return (obj ?: [UINavigationBar appearance].tintColor) ?: UIColor.blackColor;
}

- (void)setHbd_tintColor:(UIColor *)tintColor {
    objc_setAssociatedObject(self, @selector(hbd_tintColor), tintColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDictionary *)hbd_titleTextAttributes {
    id obj = objc_getAssociatedObject(self, _cmd);
    if (obj) {
        return obj;
    }

    UIBarStyle barStyle = self.hbd_barStyle;
    NSDictionary *attributes = [UINavigationBar appearance].titleTextAttributes;
    if (attributes) {
        if (!attributes[NSForegroundColorAttributeName]) {
            NSMutableDictionary *mutableAttributes = [attributes mutableCopy];
            if (barStyle == UIBarStyleBlack) {
                [mutableAttributes addEntriesFromDictionary:@{NSForegroundColorAttributeName: UIColor.whiteColor}];
            } else {
                [mutableAttributes addEntriesFromDictionary:@{NSForegroundColorAttributeName: UIColor.blackColor}];
            }
            return mutableAttributes;
        }
        return attributes;
    }

    if (barStyle == UIBarStyleBlack) {
        return @{NSForegroundColorAttributeName: UIColor.whiteColor};
    } else {
        return @{NSForegroundColorAttributeName: UIColor.blackColor};
    }
}

- (void)setHbd_titleTextAttributes:(NSDictionary *)attributes {
    objc_setAssociatedObject(self, @selector(hbd_titleTextAttributes), attributes, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)hbd_extendedLayoutDidSet {
    id obj = objc_getAssociatedObject(self, _cmd);
    return obj ? [obj boolValue] : NO;
}

- (void)setHbd_extendedLayoutDidSet:(BOOL)didSet {
    objc_setAssociatedObject(self, @selector(hbd_extendedLayoutDidSet), @(didSet), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (CGFloat)hbd_barAlpha {
    id obj = objc_getAssociatedObject(self, _cmd);
    if (self.hbd_barHidden) {
        return 0;
    }
    return obj ? [obj floatValue] : 1.0f;
}

- (void)setHbd_barAlpha:(CGFloat)alpha {
    objc_setAssociatedObject(self, @selector(hbd_barAlpha), @(alpha), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)hbd_barHidden {
    id obj = objc_getAssociatedObject(self, _cmd);
    return obj ? [obj boolValue] : NO;
}

- (void)setHbd_barHidden:(BOOL)hidden {
    if (hidden) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[UIView new]];
        self.navigationItem.titleView = [UIView new];
    } else {
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.titleView = nil;
    }
    objc_setAssociatedObject(self, @selector(hbd_barHidden), @(hidden), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)hbd_barShadowHidden {
    id obj = objc_getAssociatedObject(self, _cmd);
    return self.hbd_barHidden || obj ? [obj boolValue] : NO;
}

- (void)setHbd_barShadowHidden:(BOOL)hidden {
    objc_setAssociatedObject(self, @selector(hbd_barShadowHidden), @(hidden), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)hbd_backInteractive {
    id obj = objc_getAssociatedObject(self, _cmd);
    return obj ? [obj boolValue] : YES;
}

- (void)setHbd_backInteractive:(BOOL)interactive {
    objc_setAssociatedObject(self, @selector(hbd_backInteractive), @(interactive), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)hbd_swipeBackEnabled {
    id obj = objc_getAssociatedObject(self, _cmd);
    return obj ? [obj boolValue] : YES;
}

- (void)setHbd_swipeBackEnabled:(BOOL)enabled {
    objc_setAssociatedObject(self, @selector(hbd_swipeBackEnabled), @(enabled), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)hbd_clickBackEnabled {
    id obj = objc_getAssociatedObject(self, _cmd);
    return obj ? [obj boolValue] : YES;
}

- (void)setHbd_clickBackEnabled:(BOOL)enabled {
    objc_setAssociatedObject(self, @selector(hbd_clickBackEnabled), @(enabled), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)hbd_splitNavigationBarTransition {
    id obj = objc_getAssociatedObject(self, _cmd);
    return obj ? [obj boolValue] : NO;
}

- (void)setHbd_splitNavigationBarTransition:(BOOL)splitNavigationBarTransition {
    objc_setAssociatedObject(self, @selector(hbd_splitNavigationBarTransition), @(splitNavigationBarTransition), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)hbd_computedBarShadowAlpha {
    return self.hbd_barShadowHidden ? 0 : self.hbd_barAlpha;
}

- (UIImage *)hbd_computedBarImage {
    UIImage *image = self.hbd_barImage;
    if (!image) {
        if (self.hbd_barTintColor != nil) {
            return nil;
        }
        image = [[UINavigationBar appearance] backgroundImageForBarMetrics:UIBarMetricsDefault];
    }
    return image;
}

- (UIColor *)hbd_computedBarTintColor {
    if (self.hbd_barHidden) {
        return UIColor.clearColor;
    }

    if (self.hbd_barImage) {
        return nil;
    }

    UIColor *color = self.hbd_barTintColor;
    if (!color) {
        if ([[UINavigationBar appearance] backgroundImageForBarMetrics:UIBarMetricsDefault] != nil) {
            return nil;
        }
        if ([UINavigationBar appearance].barTintColor != nil) {
            color = [UINavigationBar appearance].barTintColor;
        } else {
            color = [UINavigationBar appearance].barStyle == UIBarStyleDefault ? [UIColor colorWithRed:247 / 255.0 green:247 / 255.0 blue:247 / 255.0 alpha:0.8] : [UIColor colorWithRed:28 / 255.0 green:28 / 255.0 blue:28 / 255.0 alpha:0.729];
        }
    }
    return color;
}

- (void)hbd_setNeedsUpdateNavigationBar {
    if (self.navigationController && [self.navigationController isKindOfClass:[HBDNavigationController class]]) {
        HBDNavigationController *nav = (HBDNavigationController *) self.navigationController;
        if (self == nav.topViewController) {
            [nav updateNavigationBarForViewController:self];
            [nav setNeedsStatusBarAppearanceUpdate];
        }
    }
}

@end
