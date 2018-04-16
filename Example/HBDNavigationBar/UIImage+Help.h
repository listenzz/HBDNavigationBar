//
//  UIImage+Help.h
//  Tuotuo
//
//  Created by yongyang on 14-4-30.
//  Copyright (c) 2014年 gainline. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Help)

+ (UIImage *)updateImageOrientation:(UIImage *)chosenImage;

+ (UIImage*)shrinkImage:(UIImage*)original size:(CGSize)size;

+ (UIImage *)imageNoCache:(NSString *)name;

+ (UIImage *)stretchableImage:(UIImage *)img edgeInsets:(UIEdgeInsets)edgeInsets;

+ (UIImage *)imageFromBundle:(NSString *)bundleName path:(NSString *)path imageName:(NSString *)imageName;

+ (UIImage*)imageWithColor:(UIColor*)color;

+ (UIImage*)imageWithColor:(UIColor*)color size:(CGSize)size;

+ (UIImage *)imageWithView:(UIView *)view rect:(CGRect)rect;

+ (UIImage *)imageWithWindowRect:(CGRect)rect;

+ (UIImage *)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize;

+ (UIImage *)imageWithImageCenterSimple:(UIImage*)image scaledToSize:(CGSize)newSize;

+ (UIImage *) croppedImageCenterSimple:(UIImage*)image scaledToSize:(CGSize)newSize;

+ (CGSize)scaleImage:(UIImage *)image sideMax:(float)sideMax;

@end
