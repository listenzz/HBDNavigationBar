//
//  UIColor+Help.h
//  Tuotuo
//
//  Created by yangyong on 14-4-28.
//  Copyright (c) 2014年 gainline. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Help)

+ (UIColor*) colorWithHex:(NSInteger)hexValue alpha:(CGFloat)alphaValue;

+ (UIColor*) colorWithHex:(NSInteger)hexValue;

+ (NSString *) hexFromUIColor: (UIColor*) color;

+ (UIColor *) colorWithHexString: (NSString *) hexString;

+ (UIColor *) colorWithHexString: (NSString *)hexString withOpacity:(NSString *)opacity;

+ (UIColor *) colorWithRgbString: (NSString *) rgbString;

+ (UIColor *) colorWithRgbaString: (NSString *) rgbaString;

+ (NSString *) rgbFromUIColor: (UIColor*) color;

+ (NSString *) rgbaFromUIColor: (UIColor*) color;

@end
