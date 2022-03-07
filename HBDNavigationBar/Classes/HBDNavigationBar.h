//
//  HBDNavigationBar.h
//  HBDNavigationBar
//
//  Created by Listen on 2018/3/23.
//

#import <UIKit/UIKit.h>

@interface HBDNavigationBar : UINavigationBar

@property(nonatomic, strong, readonly) UIImageView *shadowImageView;
@property(nonatomic, strong, readonly) UIVisualEffectView *fakeView;
@property(nonatomic, strong, readonly) UIImageView *backgroundImageView;
@property(nonatomic, strong, readonly) UILabel *backButtonLabel;
@property(nonatomic, strong, readonly) UIView *hbd_backgroundView;

@end


@interface UILabel (NavigationBarTransition)

@property(nonatomic, strong) UIColor *hbd_specifiedTextColor;

@end
