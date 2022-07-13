//
//  XYDashLineProgress.h
//  ZZDottedLineProgress
//
//  Created by 康晴 on 2019/5/4.
//  Copyright © 2019 zx. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface XYDashLineProgress : UIView

/**
 进度条进度。0-1之间。
 */
@property (nonatomic, assign) CGFloat progress;
/**
 背景圆环颜色
 */
@property (nonatomic, strong) UIColor *trackColor;

@end

NS_ASSUME_NONNULL_END
