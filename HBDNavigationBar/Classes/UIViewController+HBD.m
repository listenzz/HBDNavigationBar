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

- (UIColor *)hbd_barTintColor {
    id obj = objc_getAssociatedObject(self, _cmd);
    return obj ?: [UINavigationBar appearance].barTintColor;
}

- (void)setHbd_barTintColor:(UIColor *)tintColor {
     objc_setAssociatedObject(self, @selector(hbd_barTintColor), tintColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (float)hbd_barAlpha {
    id obj = objc_getAssociatedObject(self, _cmd);
    return obj ? [obj floatValue] : 1.0f;
}

- (void)setHbd_barAlpha:(float)alpha {
    self.hbd_barShadowAlpha = alpha;
    objc_setAssociatedObject(self, @selector(hbd_barAlpha), @(alpha), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)hbd_barHidden {
    id obj = objc_getAssociatedObject(self, _cmd);
    return obj ? [obj boolValue] : NO;
}

- (void)setHbd_barHidden:(BOOL)hidden {
    self.hbd_barAlpha = 0;
    self.hbd_barShadowHidden = YES;
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
    id obj = objc_getAssociatedObject(self, _cmd);
    return obj ? [obj floatValue] : 1.0f;
}

- (void)setHbd_barShadowAlpha:(float)alpha {
    objc_setAssociatedObject(self, @selector(hbd_barShadowAlpha), @(alpha), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)hbd_barShadowHidden {
    id obj = objc_getAssociatedObject(self, _cmd);
    return obj ? [obj boolValue] : NO;
}

- (void)setHbd_barShadowHidden:(BOOL)hidden {
    self.hbd_barShadowAlpha = hidden ? 0 : self.hbd_barAlpha;
    objc_setAssociatedObject(self, @selector(hbd_barShadowHidden), @(hidden), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)hbd_backInteractive {
    id obj = objc_getAssociatedObject(self, _cmd);
    return obj ? [obj boolValue] : YES;
}

-(void)setHbd_backInteractive:(BOOL)interactive {
    objc_setAssociatedObject(self, @selector(hbd_backInteractive), @(interactive), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
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

- (void)hbd_setNeedsUpdateNavigationBarShadowImageHidden {
    if (self.navigationController && [self.navigationController isKindOfClass:[HBDNavigationController class]]) {
        HBDNavigationController *nav = (HBDNavigationController *)self.navigationController;
        [nav updateNavigationBarShadowImageHiddenForViewController:self];
    }
}

@end
