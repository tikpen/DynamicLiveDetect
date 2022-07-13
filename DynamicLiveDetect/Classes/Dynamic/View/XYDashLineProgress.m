//
//  XYDashLineProgress.m
//  ZZDottedLineProgress
//
//  Created by 康晴 on 2019/5/4.
//  Copyright © 2019 zx. All rights reserved.
//

#import "XYDashLineProgress.h"

@interface XYDashLineProgress()

//虚线view
@property (nonatomic, strong) UIView *dashView;
//环形view
@property (nonatomic, strong) UIView *circleView;
//背景圆环
@property (nonatomic, strong) CAShapeLayer *trackerLayer;
//圆环进度条
@property (nonatomic, strong) CAShapeLayer *progressLayer;

@end

@implementation XYDashLineProgress

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self setUI];
    }
    return self;
}

- (void)setUI{
    //虚线view
    UIView *dashView = [UIView new];
    dashView.backgroundColor = [UIColor clearColor];
    dashView.frame = self.bounds;
    self.dashView = dashView;
    //虚线宽度
    CGFloat dashWidth = 2;
    //长虚线个数
    NSInteger longDashNum = 48;
    //长虚线
    CALayer *longLayer = [CALayer layer];
    longLayer.frame = CGRectMake(CGRectGetMidX(self.bounds), 0, dashWidth, 5*dashWidth);
    longLayer.backgroundColor = [UIColor whiteColor].CGColor;
    
    CAReplicatorLayer *longReplicatorLayer = [CAReplicatorLayer layer];
    longReplicatorLayer.frame = self.bounds;
    longReplicatorLayer.instanceCount = longDashNum;
    longReplicatorLayer.instanceDelay = 1.f/longDashNum;
    longReplicatorLayer.instanceTransform = CATransform3DMakeRotation(2*M_PI/longDashNum, 0, 0, 1);
    [dashView.layer addSublayer:longReplicatorLayer];
    [longReplicatorLayer addSublayer:longLayer];
    //短虚线
    CALayer *shortLayer = [CALayer layer];
    shortLayer.frame = CGRectMake(CGRectGetMidX(self.bounds), 4, dashWidth, 3*dashWidth);
    shortLayer.backgroundColor = [UIColor whiteColor].CGColor;
    
    CAReplicatorLayer *shortReplicatorLayer = [CAReplicatorLayer layer];
    shortReplicatorLayer.frame = self.bounds;
    shortReplicatorLayer.instanceCount = 2*longDashNum;
    shortReplicatorLayer.instanceDelay = 1.f/(2*longDashNum);
    shortReplicatorLayer.instanceTransform = CATransform3DMakeRotation(2*M_PI/(2*longDashNum), 0, 0, 1);
    [dashView.layer addSublayer:shortReplicatorLayer];
    [shortReplicatorLayer addSublayer:shortLayer];
    //圆形view
    UIView *circleView = [UIView new];
    circleView.frame = self.bounds;
    [self addSubview:circleView];
    self.circleView = circleView;
    //背景圆环
    CAShapeLayer *trackLayer = [CAShapeLayer layer];
    trackLayer.frame = self.bounds;
    trackLayer.fillColor = [UIColor clearColor].CGColor;
    trackLayer.strokeColor =  [UIColor colorWithRed:127/255.0f green:118/255.0f blue:113/255.0f alpha:1].CGColor;
    trackLayer.lineWidth = 20;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0) radius:self.frame.size.width/2.0 - 10 startAngle:- M_PI_2 endAngle:-M_PI_2 + M_PI * 2 clockwise:YES];
    trackLayer.path = path.CGPath;
    [circleView.layer addSublayer:trackLayer];
    self.trackerLayer = trackLayer;
    //进度view
    CAShapeLayer *progressLayer = [CAShapeLayer layer];
    progressLayer.frame = self.bounds;
    progressLayer.fillColor = [UIColor clearColor].CGColor;
    progressLayer.strokeColor =  [UIColor colorWithRed:93/255.0f green:160/255.0f blue:249/255.0f alpha:1].CGColor;
    progressLayer.lineWidth = 20;
    UIBezierPath *path1 = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0) radius:self.frame.size.width/2.0 - 10 startAngle:- M_PI_2 endAngle: - M_PI_2 clockwise:YES];
    progressLayer.path = path1.CGPath;
    [circleView.layer addSublayer:progressLayer];
    self.progressLayer = progressLayer;
    circleView.layer.mask = dashView.layer;
}

- (void)setProgress:(CGFloat)progress{
    _progress = progress;
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0) radius:self.frame.size.width/2.0 - 10 startAngle:- M_PI_2 endAngle: - M_PI_2+(2*M_PI*progress) clockwise:YES];
    self.progressLayer.path = path.CGPath;
    
    CABasicAnimation *pathAnima = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnima.duration = 0.25;
    pathAnima.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    pathAnima.fromValue = [NSNumber numberWithFloat:0.0f];
    pathAnima.toValue = [NSNumber numberWithFloat:progress];
    pathAnima.fillMode = kCAFillModeForwards;
    pathAnima.removedOnCompletion = NO;
    [self.progressLayer addAnimation:pathAnima forKey:@"strokeEndAnimation"];
}

- (void)setTrackColor:(UIColor *)trackColor{
    _trackColor = trackColor;
    self.trackerLayer.strokeColor =  trackColor.CGColor;
}

@end

