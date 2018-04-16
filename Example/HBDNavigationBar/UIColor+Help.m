//
//  UIColor+Help.m
//  Tuotuo
//
//  Created by yangyong on 14-4-28.
//  Copyright (c) 2014年 gainline. All rights reserved.
//

#import "UIColor+Help.h"

@implementation UIColor (Help)

+ (UIColor*) colorWithHex:(NSInteger)hexValue alpha:(CGFloat)alphaValue
{
    return [UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0
                           green:((float)((hexValue & 0xFF00) >> 8))/255.0
                            blue:((float)(hexValue & 0xFF))/255.0 alpha:alphaValue];
}

+ (UIColor*) colorWithHex:(NSInteger)hexValue
{
    return [UIColor colorWithHex:hexValue alpha:1.0];
}

+ (NSString *) hexFromUIColor: (UIColor*) color {
    if (CGColorGetNumberOfComponents(color.CGColor) < 4) {
        const CGFloat *components = CGColorGetComponents(color.CGColor);
        color = [UIColor colorWithRed:components[0]
                                green:components[0]
                                 blue:components[0]
                                alpha:components[1]];
    }
    
    if (CGColorSpaceGetModel(CGColorGetColorSpace(color.CGColor)) != kCGColorSpaceModelRGB) {
        return [NSString stringWithFormat:@"#FFFFFF"];
    }
    
    int red = (int)((CGColorGetComponents(color.CGColor))[0]*255.0);
    NSString *redString = red < 10 ? [NSString stringWithFormat:@"0%d",red] : [NSString stringWithFormat:@"%x",red];
    
    int green = (int)((CGColorGetComponents(color.CGColor))[1]*255.0);
    NSString *greenString = green < 10 ? [NSString stringWithFormat:@"0%d",green] : [NSString stringWithFormat:@"%x",green];
    
    int blue = (int)((CGColorGetComponents(color.CGColor))[2]*255.0);
    NSString *blueString = blue < 10 ? [NSString stringWithFormat:@"0%d",blue] : [NSString stringWithFormat:@"%x",blue];
    
    return [NSString stringWithFormat:@"#%@%@%@",redString,greenString,blueString];
}


+ (CGFloat) colorComponentFrom: (NSString *) string start: (NSUInteger) start length: (NSUInteger) length

{
    
    NSString *substring = [string substringWithRange: NSMakeRange(start, length)];
    
    NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat: @"0%@", substring];
    
    unsigned hexComponent;
    
    [[NSScanner scannerWithString: fullHex] scanHexInt: &hexComponent];
    
    return hexComponent / 255.0;
    
}



+ (UIColor *) colorWithHexString: (NSString *) hexString
{
    NSString *colorStr = [[hexString stringByReplacingOccurrencesOfString:@" " withString:@""] uppercaseString];
    if ([colorStr rangeOfString:@"#" options:NSCaseInsensitiveSearch].location == NSNotFound)
    {
        if (([colorStr rangeOfString:@"RGBA(" options:NSCaseInsensitiveSearch].location == NSNotFound) && ([colorStr rangeOfString:@"RGB(" options:NSCaseInsensitiveSearch].location == NSNotFound))
        {
            return [UIColor clearColor];
        }
        else
        {
            return [UIColor colorWithRgbaString:colorStr];
        }
    }
    else
    {
        NSString *colorString = [[hexString stringByReplacingOccurrencesOfString:@"#" withString:@""] uppercaseString];
        CGFloat alpha, red, green, blue;
        switch ([colorString length]) {
                
            case 3: // #RGB
                
                alpha = 1.0f;
                
                red   = [self colorComponentFrom: colorString start: 0 length: 1];
                
                green = [self colorComponentFrom: colorString start: 1 length: 1];
                
                blue  = [self colorComponentFrom: colorString start: 2 length: 1];
                
                break;
                
            case 4: // #ARGB
                
                alpha = [self colorComponentFrom: colorString start: 0 length: 1];
                
                red   = [self colorComponentFrom: colorString start: 1 length: 1];
                
                green = [self colorComponentFrom: colorString start: 2 length: 1];
                
                blue  = [self colorComponentFrom: colorString start: 3 length: 1];
                
                break;
                
            case 5: // #RRGGB
                
                alpha = 1.0f;
                
                red   = [self colorComponentFrom: colorString start: 0 length: 2];
                
                green = [self colorComponentFrom: colorString start: 2 length: 2];
                
                blue  = [self colorComponentFrom: colorString start: 4 length: 1];
                
                break;
                
            case 6: // #RRGGBB
                
                alpha = 1.0f;
                
                red   = [self colorComponentFrom: colorString start: 0 length: 2];
                
                green = [self colorComponentFrom: colorString start: 2 length: 2];
                
                blue  = [self colorComponentFrom: colorString start: 4 length: 2];
                
                break;
                
            case 8: // #AARRGGBB
                
                alpha = [self colorComponentFrom: colorString start: 0 length: 2];
                
                red   = [self colorComponentFrom: colorString start: 2 length: 2];
                
                green = [self colorComponentFrom: colorString start: 4 length: 2];
                
                blue  = [self colorComponentFrom: colorString start: 6 length: 2];
                
                break;
                
            case 0:
                
                alpha = 1.0f;
                
                red   = 0.0f;
                
                green = 0.0f;
                
                blue  = 0.0f;
                
                break;
                
            default:
                
                alpha = 1.0f;
                
                red   = 0.0f;
                
                green = 0.0f;
                
                blue  = 0.0f;
                
                [NSException raise:@"Invalid color value" format: @"Color value %@ is invalid.  It should be a hex value of the form #RBG, #ARGB, #RRGGBB, or #AARRGGBB", hexString];
                
                break;
                
        }
        
        return [UIColor colorWithRed: red green: green blue: blue alpha: alpha];
    }
}

+ (UIColor *) colorWithHexString: (NSString *)hexString withOpacity:(NSString *)opacity
{
    NSString *colorStr = [[hexString stringByReplacingOccurrencesOfString:@" " withString:@""] uppercaseString];
    if ([colorStr rangeOfString:@"#" options:NSCaseInsensitiveSearch].location == NSNotFound)
    {
        if (([colorStr rangeOfString:@"RGBA(" options:NSCaseInsensitiveSearch].location == NSNotFound) && ([colorStr rangeOfString:@"RGB(" options:NSCaseInsensitiveSearch].location == NSNotFound))
        {
            return [UIColor clearColor];
        }
        else
        {
            return [UIColor colorWithRgbaString:colorStr];
        }
    }
    else
    {
        NSString *colorString = [[hexString stringByReplacingOccurrencesOfString:@"#" withString:@""] uppercaseString];
        CGFloat op = [opacity floatValue];
        CGFloat alpha, red, green, blue;
        switch ([colorString length]) {
                
            case 3: // #RGB
                
                alpha = op;
                
                red   = [self colorComponentFrom: colorString start: 0 length: 1];
                
                green = [self colorComponentFrom: colorString start: 1 length: 1];
                
                blue  = [self colorComponentFrom: colorString start: 2 length: 1];
                
                break;
                
            case 4: // #ARGB
                
                alpha = [self colorComponentFrom: colorString start: 0 length: 1];
                
                red   = [self colorComponentFrom: colorString start: 1 length: 1];
                
                green = [self colorComponentFrom: colorString start: 2 length: 1];
                
                blue  = [self colorComponentFrom: colorString start: 3 length: 1];
                
                break;
                
            case 6: // #RRGGBB
                
                alpha = op;
                
                red   = [self colorComponentFrom: colorString start: 0 length: 2];
                
                green = [self colorComponentFrom: colorString start: 2 length: 2];
                
                blue  = [self colorComponentFrom: colorString start: 4 length: 2];
                
                break;
                
            case 8: // #AARRGGBB
                
                alpha = [self colorComponentFrom: colorString start: 0 length: 2];
                
                red   = [self colorComponentFrom: colorString start: 2 length: 2];
                
                green = [self colorComponentFrom: colorString start: 4 length: 2];
                
                blue  = [self colorComponentFrom: colorString start: 6 length: 2];
                
                break;
                
            case 0:
                
                alpha = 1.0f;
                
                red   = 0.0f;
                
                green = 0.0f;
                
                blue  = 0.0f;
                
                break;
                
            default:
                
                alpha = 1.0f;
                
                red   = 0.0f;
                
                green = 0.0f;
                
                blue  = 0.0f;
                
                [NSException raise:@"Invalid color value" format: @"Color value %@ is invalid.  It should be a hex value of the form #RBG, #ARGB, #RRGGBB, or #AARRGGBB", hexString];
                
                break;
                
        }
        
        return [UIColor colorWithRed: red green: green blue: blue alpha: alpha];
    }
}


+ (UIColor *) colorWithRgbString: (NSString *) rgbString
{
    NSString *colorString = [[rgbString stringByReplacingOccurrencesOfString:@" " withString:@""] uppercaseString];
    colorString = [colorString stringByReplacingOccurrencesOfString:@")" withString:@""];
    NSRange rgbRange = [colorString rangeOfString:@"RGB("];
    NSString *rgbstr = [colorString substringWithRange:rgbRange];
    colorString = [colorString stringByReplacingOccurrencesOfString:rgbstr withString:@""];
    
    CGFloat alpha, red, green, blue;
    NSArray *colorArray = [colorString componentsSeparatedByString:@","];
    if ([colorArray count] == 4)
    {
        red = [[colorArray objectAtIndex:0] floatValue]/255.0;
        green = [[colorArray objectAtIndex:1] floatValue]/255.0;
        blue = [[colorArray objectAtIndex:2] floatValue]/255.0;
        alpha = 1.0;
    }
    else
    {
        red = 1.0;
        green = 1.0;
        blue = 1.0;
        alpha = 1.0f;
    }
    
    return [UIColor colorWithRed: red green: green blue: blue alpha: alpha];
}

+ (UIColor *) colorWithRgbaString: (NSString *) rgbaString
{
    NSString *colorString = [[rgbaString stringByReplacingOccurrencesOfString:@" " withString:@""] uppercaseString];
    colorString = [colorString stringByReplacingOccurrencesOfString:@")" withString:@""];
    NSRange rgbRange = [colorString rangeOfString:@"RGBA("];
    NSString *rgbstr = [colorString substringWithRange:rgbRange];
    colorString = [colorString stringByReplacingOccurrencesOfString:rgbstr withString:@""];

    CGFloat alpha, red, green,blue;
    NSArray *colorArray = [colorString componentsSeparatedByString:@","];
    if ([colorArray count] == 4)
    {
        red = [[colorArray objectAtIndex:0] floatValue]/255.0f;
        green = [[colorArray objectAtIndex:1] floatValue]/255.0f;
        blue = [[colorArray objectAtIndex:2] floatValue]/255.0f;
        alpha = [[colorArray objectAtIndex:3] floatValue];
    }
    else
    {
        red = 1.0;
        green = 1.0;
        blue = 1.0;
        alpha = 1.0f;
    }
    
    return [UIColor colorWithRed: red green: green blue: blue alpha: alpha];

}

+ (NSString *) rgbFromUIColor: (UIColor*) color
{
    if (CGColorGetNumberOfComponents(color.CGColor) < 4) {
        const CGFloat *components = CGColorGetComponents(color.CGColor);
        color = [UIColor colorWithRed:components[0]
                                green:components[0]
                                 blue:components[0]
                                alpha:components[1]];
    }
    
    if (CGColorSpaceGetModel(CGColorGetColorSpace(color.CGColor)) != kCGColorSpaceModelRGB) {
        return [NSString stringWithFormat:@"rgb(1,1,1)"];
    }
    
    return [NSString stringWithFormat:@"rgba(%.0f,%.0f,%.0f)", (CGFloat)((CGColorGetComponents(color.CGColor))[0]*255.0),
            (CGFloat)((CGColorGetComponents(color.CGColor))[1]*255.0),
            (CGFloat)((CGColorGetComponents(color.CGColor))[2]*255.0)
            ];
}

+ (NSString *) rgbaFromUIColor: (UIColor*) color
{
    if (CGColorGetNumberOfComponents(color.CGColor) < 4) {
        const CGFloat *components = CGColorGetComponents(color.CGColor);
        color = [UIColor colorWithRed:components[0]
                                green:components[0]
                                 blue:components[0]
                                alpha:components[1]];
    }
    
    if (CGColorSpaceGetModel(CGColorGetColorSpace(color.CGColor)) != kCGColorSpaceModelRGB) {
        return [NSString stringWithFormat:@"rgb(1,1,1,1)"];
    }
    
    return [NSString stringWithFormat:@"rgba(%.0f,%.0f,%.0f,%.0f)", (CGFloat)((CGColorGetComponents(color.CGColor))[0]*255.0),
            (CGFloat)((CGColorGetComponents(color.CGColor))[1]*255.0),
            (CGFloat)((CGColorGetComponents(color.CGColor))[2]*255.0),
            (CGFloat)((CGColorGetComponents(color.CGColor))[3])
            ];
}

@end
