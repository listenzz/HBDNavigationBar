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

- (UIBarStyle)hbd_barStyle {
    id obj = objc_getAssociatedObject(self, _cmd);
    if (obj) {
        return [obj integerValue];
    }
    return [UINavigationBar appearance].barStyle;
}

- (void)setHbd_barStyle:(UIBarStyle)hbd_barStyle {
    objc_setAssociatedObject(self, @selector(hbd_barStyle), @(hbd_barStyle), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)hbd_barTintColor {
    if (self.hbd_barHidden) {
        return UIColor.clearColor;
    }
    
    id obj = objc_getAssociatedObject(self, _cmd);
    if (obj) {
        return obj;
    }
    
    if ([UINavigationBar appearance].barTintColor) {
        return [UINavigationBar appearance].barTintColor;
    }
    return [UINavigationBar appearance].barStyle == UIBarStyleDefault ? [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:0.8]: [UIColor colorWithRed:28/255.0 green:28/255.0 blue:28/255.0 alpha:0.729];
}

- (void)setHbd_barTintColor:(UIColor *)tintColor {
     objc_setAssociatedObject(self, @selector(hbd_barTintColor), tintColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (float)hbd_barAlpha {
    id obj = objc_getAssociatedObject(self, _cmd);
    if (self.hbd_barHidden) {
        return 0;
    }
    return obj ? [obj floatValue] : 1.0f;
}

- (void)setHbd_barAlpha:(float)alpha {
    objc_setAssociatedObject(self, @selector(hbd_barAlpha), @(alpha), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
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
    objc_setAssociatedObject(self, @selector(hbd_barHidden), @(hidden), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (float)hbd_barShadowAlpha {
    return  self.hbd_barShadowHidden ? 0 : self.hbd_barAlpha;
}

- (BOOL)hbd_barShadowHidden {
    id obj = objc_getAssociatedObject(self, _cmd);
    return  self.hbd_barHidden || obj ? [obj boolValue] : NO;
}

- (void)setHbd_barShadowHidden:(BOOL)hidden {
    objc_setAssociatedObject(self, @selector(hbd_barShadowHidden), @(hidden), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)hbd_backInteractive {
    id obj = objc_getAssociatedObject(self, _cmd);
    return obj ? [obj boolValue] : YES;
}

-(void)setHbd_backInteractive:(BOOL)interactive {
    objc_setAssociatedObject(self, @selector(hbd_backInteractive), @(interactive), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)hbd_setNeedsUpdateNavigationBar {
    if (self.navigationController && [self.navigationController isKindOfClass:[HBDNavigationController class]]) {
        HBDNavigationController *nav = (HBDNavigationController *)self.navigationController;
        [nav updateNavigationBarForController:self];
    }
}

-(void)hbd_setNeedsUpdateNavigationBarAlpha {
    if (self.navigationController && [self.navigationController isKindOfClass:[HBDNavigationController class]]) {
        HBDNavigationController *nav = (HBDNavigationController *)self.navigationController;
        [nav updateNavigationBarAlphaForViewController:self];
    }
}

- (void)hbd_setNeedsUpdateNavigationBarColor {
    if (self.navigationController && [self.navigationController isKindOfClass:[HBDNavigationController class]]) {
        HBDNavigationController *nav = (HBDNavigationController *)self.navigationController;
        [nav updateNavigationBarColorForViewController:self];
    }
}

- (void)hbd_setNeedsUpdateNavigationBarShadowImageAlpha {
    if (self.navigationController && [self.navigationController isKindOfClass:[HBDNavigationController class]]) {
        HBDNavigationController *nav = (HBDNavigationController *)self.navigationController;
        [nav updateNavigationBarShadowImageAlphaForViewController:self];
    }
}

@end
