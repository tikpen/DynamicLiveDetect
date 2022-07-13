//
//  UIView+Frame.h
//  MIPAI
//
//  Created by WangYu on 2017/9/6.
//  Copyright © 2017年 WangYu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (ZPFrame)
// shortcuts for frame properties
@property (nonatomic, assign) CGPoint origin;
@property (nonatomic, assign) CGSize size;

// shortcuts for positions
@property (nonatomic) CGFloat centerX;
@property (nonatomic) CGFloat centerY;

@property (nonatomic) CGFloat X;
@property (nonatomic) CGFloat Y;

@property (nonatomic) CGFloat top;
@property (nonatomic) CGFloat bottom;
@property (nonatomic) CGFloat right;
@property (nonatomic) CGFloat left;

@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;

/**
 快速给View添加4边阴影
 参数:阴影透明度，默认0
 */
- (void)addProjectionWithShadowOpacity:(CGFloat)shadowOpacity;
/**
 快速给View添加4边框
 参数:边框宽度
 */
- (void)addBorderWithWidth:(CGFloat)width;
/**
 快速给View添加4边框
 width:边框宽度
 borderColor:边框颜色
 */
- (void)addBorderWithWidth:(CGFloat)width borderColor:(UIColor *)borderColor;
/**
 快速给View添加圆角
 参数:圆角半径
 */
- (void)addRoundedCornersWithRadius:(CGFloat)radius;
/**
 快速给View添加圆角
 radius:圆角半径
 corners:且那几个角
 类型共有以下几种:
 typedef NS_OPTIONS(NSUInteger, UIRectCorner) {
 UIRectCornerTopLeft,
 UIRectCornerTopRight ,
 UIRectCornerBottomLeft,
 UIRectCornerBottomRight,
 UIRectCornerAllCorners
 };
 使用案例:[self.mainView addRoundedCornersWithRadius:10 byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight]; // 切除了左下 右下
 */
- (void)addRoundedCornersWithRadius:(CGFloat)radius byRoundingCorners:(UIRectCorner)corners;
- (void)addRoundedCornersWithRadius:(CGFloat)radius byRoundingCorners:(UIRectCorner)corners bounds:(CGRect)bounds;
@end
