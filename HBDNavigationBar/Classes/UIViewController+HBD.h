//
//  UIViewController+HBD.h
//  HBDNavigationBar
//
//  Created by Listen on 2018/3/23.
//

#import <UIKit/UIKit.h>

@interface UIViewController (HBD)

@property (nonatomic, assign) UIBarStyle hbd_barStyle;
@property (nonatomic, strong) UIColor *hbd_barTintColor;
@property (nonatomic, strong) UIImage *hbd_barImage;
@property (nonatomic, strong) UIColor *hbd_tintColor;
@property (nonatomic, strong) NSDictionary *hbd_titleTextAttributes;
@property (nonatomic, assign) float hbd_barAlpha;
@property (nonatomic, assign) BOOL hbd_barHidden;
@property (nonatomic, assign) BOOL hbd_barShadowHidden;
@property (nonatomic, assign) BOOL hbd_backInteractive;

// computed
@property (nonatomic, assign, readonly) float hbd_computedBarShadowAlpha;
@property (nonatomic, strong, readonly) UIColor *hbd_computedBarTintColor;
@property (nonatomic, strong, readonly) UIImage *hbd_computedBarImage;

- (void)hbd_setNeedsUpdateNavigationBar;
- (void)hbd_setNeedsUpdateNavigationBarAlpha;
- (void)hbd_setNeedsUpdateNavigationBarColorOrImage;
- (void)hbd_setNeedsUpdateNavigationBarShadowAlpha;

@end
