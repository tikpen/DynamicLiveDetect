//
//  UIView+XYCapture.h
//  FRAS
//
//  Created by 康晴晴 on 2019/5/4.
//  Copyright © 2019 WYFeng. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (XYCapture)

+ (UIImage *)xy_captureWithView:(UIView *)view;

+ (UIImage *)xy_captureWithView:(UIView *)view inRect:(CGRect)captureRect;

@end

NS_ASSUME_NONNULL_END
