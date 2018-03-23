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

+ (UIImageView *)findShadowImageAt:(UINavigationBar *)bar {
    NSArray *subViews = [self allSubviews:bar];
    for (UIView *view in subViews) {
        if ([view isKindOfClass:[UIImageView class]] && view.bounds.size.height <= 1){
            return (UIImageView *)view;
        }
    }
    return nil;
}

+ (NSArray *)allSubviews:(UIView *)aView {
    NSArray *results = [aView subviews];
    for (UIView *eachView in aView.subviews)
    {
        NSArray *subviews = [self allSubviews: eachView];
        if (subviews)
            results = [results arrayByAddingObjectsFromArray:subviews];
    }
    return results;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _shadowImageAlpha = 1.0;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        _shadowImageAlpha = 1.0;
    }
    return self;
}

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
    if (@available(iOS 11.0, *)) {
        self.shadowImageView.alpha = self.shadowImageAlpha;
    }
    self.fakeView.frame = self.fakeView.superview.bounds;
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

- (void)setBarTintColor:(UIColor *)barTintColor {
    [super setBarTintColor:barTintColor];
    self.fakeView.backgroundColor = barTintColor;
}

- (void)setShadowImageAlpha:(float)shadowAlpha {
    _shadowImageAlpha = shadowAlpha;
    self.shadowImageView.alpha = shadowAlpha;
}

- (UIImageView *)shadowImageView {
    if (!_shadowImageView) {
        _shadowImageView = [HBDNavigationBar findShadowImageAt:self];
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

