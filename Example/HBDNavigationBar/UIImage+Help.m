//
//  UIImage+Help.m
//  Tuotuo
//
//  Created by yongyang on 14-4-30.
//  Copyright (c) 2014年 gainline. All rights reserved.
//

#import "UIImage+Help.h"

@implementation UIImage (Help)

+ (UIImage *)updateImageOrientation:(UIImage *)chosenImage
{
    if (chosenImage) {
        // No-op if the orientation is already correct
        if (chosenImage.imageOrientation == UIImageOrientationUp){
            return chosenImage;
        }
        else{
            
            // We need to calculate the proper transformation to make the image upright.
            // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
            CGAffineTransform transform = CGAffineTransformIdentity;
            UIImageOrientation orientation=chosenImage.imageOrientation;
            int orientation_=orientation;
            switch (orientation_) {
                case UIImageOrientationDown:
                case UIImageOrientationDownMirrored:
                    transform = CGAffineTransformTranslate(transform, chosenImage.size.width, chosenImage.size.height);
                    transform = CGAffineTransformRotate(transform, M_PI);
                    break;
                    
                case UIImageOrientationLeft:
                case UIImageOrientationLeftMirrored:
                    transform = CGAffineTransformTranslate(transform, chosenImage.size.width, 0);
                    transform = CGAffineTransformRotate(transform, M_PI_2);
                    break;
                    
                case UIImageOrientationRight:
                case UIImageOrientationRightMirrored:
                    transform = CGAffineTransformTranslate(transform, 0, chosenImage.size.height);
                    transform = CGAffineTransformRotate(transform, -M_PI_2);
                    break;
            }
            
            switch (orientation_) {
                case UIImageOrientationUpMirrored:{
                    
                }
                case UIImageOrientationDownMirrored:
                    transform = CGAffineTransformTranslate(transform, chosenImage.size.width, 0);
                    transform = CGAffineTransformScale(transform, -1, 1);
                    break;
                    
                case UIImageOrientationLeftMirrored:
                case UIImageOrientationRightMirrored:
                    transform = CGAffineTransformTranslate(transform, chosenImage.size.height, 0);
                    transform = CGAffineTransformScale(transform, -1, 1);
                    break;
            }
            
            // Now we draw the underlying CGImage into a new context, applying the transform
            // calculated above.
            CGContextRef ctx = CGBitmapContextCreate(NULL, chosenImage.size.width, chosenImage.size.height,
                                                     CGImageGetBitsPerComponent(chosenImage.CGImage), 0,
                                                     CGImageGetColorSpace(chosenImage.CGImage),
                                                     CGImageGetBitmapInfo(chosenImage.CGImage));
            CGContextConcatCTM(ctx, transform);
            switch (chosenImage.imageOrientation) {
                case UIImageOrientationLeft:
                case UIImageOrientationLeftMirrored:
                case UIImageOrientationRight:
                case UIImageOrientationRightMirrored:
                    // Grr...
                    CGContextDrawImage(ctx, CGRectMake(0,0,chosenImage.size.height,chosenImage.size.width), chosenImage.CGImage);
                    break;
                    
                default:
                    CGContextDrawImage(ctx, CGRectMake(0,0,chosenImage.size.width,chosenImage.size.height), chosenImage.CGImage);
                    break;
            }
            // And now we just create a new UIImage from the drawing context
            CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
            UIImage *img = [UIImage imageWithCGImage:cgimg];
            CGContextRelease(ctx);
            CGImageRelease(cgimg);
            return img;
        }
    }
    return nil;
}

+ (UIImage*)shrinkImage:(UIImage*)original size:(CGSize)size {
    CGFloat scale = [UIScreen mainScreen].scale;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1
    int bitmapInfo = kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedFirst;
#else
    int bitmapInfo = kCGImageAlphaPremultipliedFirst;
#endif
    
    CGContextRef context = CGBitmapContextCreate(NULL, size.width * scale,
                                                 size.height * scale, 8, 0, colorSpace, bitmapInfo);
    CGContextDrawImage(context,
                       CGRectMake(0, 0, size.width * scale, size.height * scale),
                       original.CGImage);
    CGImageRef shrunken = CGBitmapContextCreateImage(context);
    UIImage *final = [UIImage imageWithCGImage:shrunken];
    
    CGContextRelease(context);
    CGImageRelease(shrunken);
    
    return final;
}

#pragma mark - 创建mainBundle目录下不带缓存的图片
+ (UIImage *)imageNoCache:(NSString *)name
{
    return [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] bundlePath], name]];
}

#pragma mark - 可拉伸的图片
+ (UIImage *)stretchableImage:(UIImage *)img edgeInsets:(UIEdgeInsets)edgeInsets{
    edgeInsets.top < 1 ? edgeInsets.top = 12 : 0;
    edgeInsets.left  < 1 ? edgeInsets.left = 12 : 0;
    edgeInsets.bottom < 1 ? edgeInsets.bottom = 12 : 0;
    edgeInsets.right  < 1 ? edgeInsets.right = 12 : 0;
#if defined __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_5_0
    return [img resizableImageWithCapInsets:edgeInsets];
#else
    return [img stretchableImageWithLeftCapWidth:edgeInsets.left topCapHeight:edgeInsets.top];
#endif
}

+ (UIImage *)imageFromBundle:(NSString *)bundleName path:(NSString *)path imageName:(NSString *)imageName
{
    NSMutableString *fullName = [[NSMutableString alloc] initWithString:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:bundleName]];
    if (path && path.length > 0)
    {
        [fullName appendString:@"/"];
        [fullName appendString:path];
    }
    if (imageName && imageName.length > 0)
    {
        [fullName appendString:@"/"];
        [fullName appendString:imageName];
    }
    return [UIImage imageWithContentsOfFile:fullName];
}

#pragma mark - UIColor转UIImage
+ (UIImage*)imageWithColor:(UIColor*)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 8.0f, 8.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage*theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

#pragma mark - UIColor转UIImage
+ (UIImage*)imageWithColor:(UIColor*)color size:(CGSize)size
{
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage*theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

+ (UIImage *)imageWithView:(UIView *)view rect:(CGRect)rect
{
    
    UIGraphicsBeginImageContextWithOptions(view.frame.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
//    if (rect.origin.x != 0 && rect.origin.x != 0) {
//        CGImageRef imageRef = CGImageCreateWithImageInRect(img.CGImage, rect);
//        img = [UIImage imageWithCGImage:imageRef];
//    }
    
    return img;
}

+ (UIImage *)imageWithWindowRect:(CGRect)rect
{
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
//    NSLog(@"%@", NSStringFromCGSize(window.bounds.size));
    UIGraphicsBeginImageContextWithOptions(window.bounds.size, NO, 0.0);
    [window.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
   UIGraphicsEndImageContext();
    
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:img];
    
    UIGraphicsBeginImageContextWithOptions(rect.size, imageView.opaque, 0.0);
    [imageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

#pragma mark - 将图片大小转换成新尺寸
+ (UIImage *)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);//根据当前大小创建一个基于位图图形的环境
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];//根据新的尺寸画出传过来的图片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();//从当前环境当中得到重绘的图片
    UIGraphicsEndImageContext();//关闭当前环境
    return newImage;
}



#pragma mark - 将图片大小转换成新尺寸
+ (UIImage *)imageWithImageCenterSimple:(UIImage*)image scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);//根据当前大小创建一个基于位图图形的环境
    [image drawInRect:CGRectMake((image.size.width - newSize.width)/2.0,
                                 (image.size.height - newSize.height)/2.0,
                                 newSize.width*2,
                                 newSize.height*2)];//根据新的尺寸画出传过来的图片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();//从当前环境当中得到重绘的图片
    UIGraphicsEndImageContext();//关闭当前环境
    return newImage;
}


+ (UIImage *) croppedImageCenterSimple:(UIImage*)image scaledToSize:(CGSize)newSize
{
    CGSize size = CGSizeZero;
    
    if (newSize.width >= newSize.height) {
        size.width = image.size.width;
        size.height = size.width * newSize.height/newSize.width;
    }
    
    if (newSize.height >= newSize.width) {
        size.height = image.size.height;
        size.width = size.height * newSize.width/newSize.height;
    }
    
    
    
    CGRect cropRect = CGRectMake((image.size.width - size.width)/2.0,
                                 (image.size.height - size.height)/2.0,
                                 size.width,
                                 size.height);
    
//    NSLog(@"---------- cropRect: %@", NSStringFromCGRect(cropRect));
//    NSLog(@"--- self.photo.size: %@", NSStringFromCGSize(self.photo.size));
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
    UIImage *result = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    NSLog(@"------- result.size: %@", NSStringFromCGSize(result.size));
    
    return result;
}




+ (CGSize)scaleImage:(UIImage *)image sideMax:(float)sideMax
{
    if (!image)
        return CGSizeZero;
    CGSize size ;
    if (image.size.height > image.size.width)
    {
        size.height = sideMax;
        size.width = image.size.width/image.size.height*sideMax;
    }
    else
    {
        size.width = sideMax;
        size.height = image.size.height/image.size.width*sideMax;
    }
    return size;
}
@end
