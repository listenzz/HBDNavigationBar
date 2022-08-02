//
//  HBDNavigationBar.m
//  HBDNavigationBar
//
//  Created by Listen on 2018/3/23.
//

#import "HBDNavigationBar.h"
#import <objc/runtime.h>

#define hairlineWidth (1.f/[UIScreen mainScreen].scale)

static void hbd_exchangeImplementations(Class class, SEL originalSelector, SEL swizzledSelector) {
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);

    BOOL success = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    if (success) {
        class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

//static UIView* findViewByName(UIView *view, NSString *name) {
//    NSString *viewName = [[[view classForCoder] description] stringByReplacingOccurrencesOfString:@"_" withString:@""];
//    if ([viewName isEqualToString:name]) {
//        return view;
//    }
//
//    UIView *v = nil;
//
//    if (view.subviews.count > 0) {
//        for (UIView *sub in view.subviews) {
//            v = findViewByName(sub, name);
//            if (v != nil) {
//                break;
//            }
//        }
//    }
//
//    return v;
//}

@interface HBDNavigationBar ()

@property(nonatomic, strong, readwrite) UIImageView *shadowImageView;
@property(nonatomic, strong, readwrite) UIVisualEffectView *fakeView;
@property(nonatomic, strong, readwrite) UIImageView *backgroundImageView;

@end

@implementation HBDNavigationBar

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (!self.isUserInteractionEnabled || self.isHidden || self.alpha <= 0.01) {
        return nil;
    }

    UIView *view = [super hitTest:point withEvent:event];
    NSString *viewName = [[[view classForCoder] description] stringByReplacingOccurrencesOfString:@"_" withString:@""];

    if ([view isKindOfClass:[self class]]) {
        for (UIView *subview in self.subviews) {
            NSString *viewName = [[[subview classForCoder] description] stringByReplacingOccurrencesOfString:@"_" withString:@""];
            NSArray *array = @[@"UINavigationItemButtonView"];
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

    NSArray *array = @[@"UINavigationBarContentView", @"UIButtonBarStackView", NSStringFromClass([self class])];
    if ([array containsObject:viewName]) {
        if (self.backgroundImageView.image) {
            if (self.backgroundImageView.alpha < 0.01) {
                return nil;
            }
        } else if (self.fakeView.alpha < 0.01) {
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
    self.backgroundImageView.frame = self.backgroundImageView.superview.bounds;
    self.shadowImageView.frame = CGRectMake(0, CGRectGetHeight(self.shadowImageView.superview.bounds) - hairlineWidth, CGRectGetWidth(self.shadowImageView.superview.bounds), hairlineWidth);
}

- (void)setBarTintColor:(UIColor *)barTintColor {
    self.fakeView.subviews.lastObject.backgroundColor = barTintColor;
    [self makeSureFakeView];
}

- (UIVisualEffectView *)fakeView {
    if (!_fakeView) {
        [super setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        _fakeView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
        _fakeView.userInteractionEnabled = NO;
        _fakeView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [[self.subviews firstObject] insertSubview:_fakeView atIndex:0];
    }
    return _fakeView;
}

- (UIImageView *)backgroundImageView {
    if (!_backgroundImageView) {
        _backgroundImageView = [[UIImageView alloc] init];
        _backgroundImageView.userInteractionEnabled = NO;
        _backgroundImageView.contentScaleFactor = 1;
        _backgroundImageView.contentMode = UIViewContentModeScaleToFill;
        _backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [[self.subviews firstObject] insertSubview:_backgroundImageView aboveSubview:self.fakeView];
    }
    return _backgroundImageView;
}

- (UILabel *)backButtonLabel {
    if (@available(iOS 11, *)); else return nil;
    UIView *navigationBarContentView = [self valueForKeyPath:@"visualProvider.contentView"];
    __block UILabel *backButtonLabel = nil;
    [navigationBarContentView.subviews enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(__kindof UIView *_Nonnull subview, NSUInteger idx, BOOL *_Nonnull stop) {
        if ([subview isKindOfClass:NSClassFromString(@"_UIButtonBarButton")]) {
            UIButton *titleButton = [subview valueForKeyPath:@"visualProvider.titleButton"];
            backButtonLabel = titleButton.titleLabel;
            *stop = YES;
        }
    }];
    return backButtonLabel;
}

- (void)setBackgroundImage:(UIImage *)backgroundImage forBarMetrics:(UIBarMetrics)barMetrics {
    self.backgroundImageView.image = backgroundImage;
    [self makeSureFakeView];
}

- (UIView *)hbd_backgroundView {
    return [self valueForKey:@"_backgroundView"];
}

- (void)setTranslucent:(BOOL)translucent {
    // prevent default behavior
    [super setTranslucent:YES];
}

- (void)setShadowImage:(UIImage *)shadowImage {
    self.shadowImageView.image = shadowImage;
    if (shadowImage) {
        self.shadowImageView.backgroundColor = nil;
    } else {
        self.shadowImageView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:77.0 / 255];
    }
}

- (UIImageView *)shadowImageView {
    if (!_shadowImageView) {
        [super setShadowImage:[UIImage new]];
        _shadowImageView = [[UIImageView alloc] init];
        _shadowImageView.userInteractionEnabled = NO;
        _shadowImageView.contentScaleFactor = 1;
        _shadowImageView.layer.allowsEdgeAntialiasing = YES;
        [[self.subviews firstObject] insertSubview:_shadowImageView aboveSubview:self.backgroundImageView];
    }
    return _shadowImageView;
}

- (void)makeSureFakeView {
    [UIView setAnimationsEnabled:NO];
    if (!self.fakeView.superview) {
        [[self.subviews firstObject] insertSubview:_fakeView atIndex:0];
        self.fakeView.frame = self.fakeView.superview.bounds;

    }

    if (!self.shadowImageView.superview) {
        [[self.subviews firstObject] insertSubview:_shadowImageView aboveSubview:self.backgroundImageView];
        self.shadowImageView.frame = CGRectMake(0, CGRectGetHeight(self.shadowImageView.superview.bounds) - hairlineWidth, CGRectGetWidth(self.shadowImageView.superview.bounds), hairlineWidth);
    }

    if (!self.backgroundImageView.superview) {
        [[self.subviews firstObject] insertSubview:_backgroundImageView aboveSubview:self.fakeView];
        self.backgroundImageView.frame = self.backgroundImageView.superview.bounds;
    }
    [UIView setAnimationsEnabled:YES];
}

@end


@implementation UILabel (NavigationBarTransition)

- (UIColor *)hbd_specifiedTextColor {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setHbd_specifiedTextColor:(UIColor *)color {
    objc_setAssociatedObject(self, @selector(hbd_specifiedTextColor), color, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (void)load {
    if (@available(iOS 11, *)); else return;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        hbd_exchangeImplementations(class, @selector(setAttributedText:), @selector(hbd_setAttributedText:));
    });
}

- (void)hbd_setAttributedText:(NSAttributedString *)attributedText {
    if (self.hbd_specifiedTextColor) {
        NSMutableAttributedString *mutableAttributedText = [attributedText isKindOfClass:NSMutableAttributedString.class] ? attributedText : [attributedText mutableCopy];
        [mutableAttributedText addAttributes:@{NSForegroundColorAttributeName: self.hbd_specifiedTextColor} range:NSMakeRange(0, mutableAttributedText.length)];
        attributedText = mutableAttributedText;
    }
    [self hbd_setAttributedText:attributedText];
}


@end
