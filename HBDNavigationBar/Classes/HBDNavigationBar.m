//
//  HBDNavigationBar.m
//  HBDNavigationBar
//
//  Created by Listen on 2018/3/23.
//

#import "HBDNavigationBar.h"

@interface HBDNavigationBar()

@property (nonatomic, strong, readwrite) UIView *alphaView;
@property (nonatomic, strong, readwrite) UIImageView *shadowImageView;
@property (nonatomic, strong) UIView *fakeView;

@end

@implementation HBDNavigationBar

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (!self.isUserInteractionEnabled || self.isHidden || self.alpha <= 0.01) {
        return nil;
    }
    
    UIView *view = [super hitTest:point withEvent:event];
    NSString *viewName = [[[view classForCoder] description] stringByReplacingOccurrencesOfString:@"_" withString:@""];
    
    if (view && [viewName isEqualToString:@"HBDNavigationBar"]) {
        for (UIView *subview in self.subviews) {
            NSString *viewName = [[[subview classForCoder] description] stringByReplacingOccurrencesOfString:@"_" withString:@""];
            NSArray *array = @[ @"UINavigationItemButtonView" ];
            if ([array containsObject:viewName]) {
                CGPoint convertedPoint = [self convertPoint:point toView:subview];
                CGRect bounds = subview.bounds;
                if (bounds.size.width < 80) {
                    bounds = CGRectInset(bounds, bounds.size.width - 80, 0);
                }
                if (CGRectContainsPoint(bounds, convertedPoint)) {
                    return view;
                }
            }
        }
    }
    
    NSArray *array = @[ @"UINavigationBarContentView", @"HBDNavigationBar" ];
    if ([array containsObject:viewName]) {
        if (self.alphaView.alpha < 0.01) {
            return nil;
        }
    }
    
    if (CGRectEqualToRect(view.bounds, CGRectZero)) {
        return nil;
    }
    
    return view;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.fakeView.frame = self.fakeView.superview.bounds;
    self.shadowImageView.frame = CGRectMake(0, CGRectGetHeight(self.shadowImageView.superview.bounds), CGRectGetWidth(self.shadowImageView.superview.bounds), 0.5);
}

- (void)setBarTintColor:(UIColor *)barTintColor {
    [super setBarTintColor:barTintColor];
    self.fakeView.backgroundColor = barTintColor;
}

- (void)setShadowImage:(UIImage *)shadowImage {
    self.shadowImageView.image = shadowImage;
    if (shadowImage) {
        self.shadowImageView.backgroundColor = nil;
    } else {
        self.shadowImageView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:77.0/255];
    }
}

- (UIView *)fakeView {
    if (!_fakeView) {
        [self setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        _fakeView = [[UIView alloc] init];
        _fakeView.userInteractionEnabled = NO;
        _fakeView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [[self.subviews firstObject] insertSubview:_fakeView atIndex:0];
    }
    return _fakeView;
}

- (UIImageView *)shadowImageView {
    if (!_shadowImageView) {
        [super setShadowImage:[UIImage new]];
        _shadowImageView = [[UIImageView alloc] init];
        _shadowImageView.userInteractionEnabled = NO;
        _shadowImageView.contentScaleFactor = 1;
        [[self.subviews firstObject] insertSubview:_shadowImageView aboveSubview:self.fakeView];
    }
    return _shadowImageView;
}

- (UIView *)alphaView {
    if (_alphaView) {
        return _alphaView;
    }
    
    id backgroundView = self.subviews[0];
    UIView *alphaView;
    if ([self isTranslucent]) {
        if (@available(iOS 10.0, *)) {
            UIImage *backgroundImage = [self backgroundImageForBarMetrics:UIBarMetricsDefault];
            if (!backgroundImage) {
                alphaView = [backgroundView valueForKey:@"_backgroundEffectView"];
            }
        } else {
            UIView *adaptiveBackdrop = [backgroundView valueForKey:@"_adaptiveBackdrop"];
            alphaView = adaptiveBackdrop;
        }
    }
    
    if (!alphaView) {
        alphaView = self.fakeView;
    }
    
    _alphaView = alphaView;
    return alphaView;
}

@end

