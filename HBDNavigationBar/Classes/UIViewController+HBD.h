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
@property (nonatomic, assign) float hbd_barAlpha;
@property (nonatomic, assign) BOOL hbd_barHidden;
@property (nonatomic, assign, readonly) float hbd_barShadowAlpha;
@property (nonatomic, assign) BOOL hbd_barShadowHidden;
@property (nonatomic, assign) BOOL hbd_backInteractive;

- (void)hbd_setNeedsUpdateNavigationBar;
- (void)hbd_setNeedsUpdateNavigationBarAlpha;
- (void)hbd_setNeedsUpdateNavigationBarColor;
- (void)hbd_setNeedsUpdateNavigationBarShadowImageAlpha;

@end
