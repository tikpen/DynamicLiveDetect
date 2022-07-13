//
//  UIView+XYCapture.m
//  FRAS
//
//  Created by 康晴晴 on 2019/5/4.
//  Copyright © 2019 WYFeng. All rights reserved.
//

#import "UIView+XYCapture.h"

@implementation UIView (XYCapture)

+ (UIImage *)xy_captureWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, [UIScreen mainScreen].scale);
    // IOS7及其后续版本
    if ([view respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
        [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:NO];
    } else { // IOS7之前的版本
        [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    }
    
    UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return screenshot;
}

+ (UIImage *)xy_captureWithView:(UIView *)view inRect:(CGRect)captureRect
{
    
    UIGraphicsBeginImageContextWithOptions(view.bounds.size,0, 1.0);
    // IOS7及其后续版本
    if ([view respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
        [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:NO];
    } else { // IOS7之前的版本
        [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    CGRect myImageRect = captureRect;
    CGImageRef imageRef = image.CGImage;
    CGImageRef subImageRef = CGImageCreateWithImageInRect(imageRef,myImageRect );
    UIImage *retImg = [UIImage imageWithCGImage:subImageRef];
    CGImageRelease(subImageRef);
    
    return retImg;
}


@end
