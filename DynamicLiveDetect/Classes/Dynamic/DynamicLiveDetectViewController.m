//
//  DynamicLiveDetectViewController.m
//  FRAS
//
//  Created by 马畅 on 2020/11/25.
//  Copyright © 2020 WYFeng. All rights reserved.
//

#import "DynamicLiveDetectViewController.h"
#import "FUOpenGLView.h"
#import "FUCamera.h"
#import "FUImageHelper.h"
#import "XYDashLineProgress.h"
#import "UIView+XYCapture.h"
#import "UIView+ZPFrame.h"
#import "LLGifImageView.h"
#import <MNNFaceDetection/MNNFaceDetection.h>
#import <MNNFaceDetection/MNNFaceDetector.h>
#import <CoreMotion/CoreMotion.h>
#import <MBProgressHUD.h>
#import <Masonry.h>

#define kSuitSize(height) (height*(KScreenW/(375.f)))
#define kRoundRadius (kSuitSize(308)/2.f)
#define kRoundTop 120

//屏幕size
#define KScreenW [UIScreen mainScreen].bounds.size.width
#define KScreenH [UIScreen mainScreen].bounds.size.height

@interface DynamicLiveDetectViewController () <FUCameraDelegate>
{
    dispatch_semaphore_t signal;
    dispatch_semaphore_t semaphore;
}
@property (nonatomic, strong) FUCamera *mCamera ;
@property (nonatomic, strong) FUOpenGLView *renderView;
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) XYDashLineProgress *progressView;
@property (nonatomic, strong) LLGifImageView *avartImg;
@property (nonatomic, strong) UILabel *tipLab;
@property (nonatomic, strong) UILabel *countDownLabel;
@property (nonatomic) NSTimer *countDownTimer;
@property (nonatomic) NSInteger countDownIndex;
@property (nonatomic, strong) UIVisualEffectView *gussianBlurView;

@property (nonatomic) NSInteger actionCount;
@property (nonatomic) NSDictionary *faceAction;
@property (strong, nonatomic) MNNFaceDetector *faceDetector;
@property (nonatomic, strong) CMMotionManager *motionManager;// 设备传感器
@property (nonatomic, assign) int deviecAutoRotateAngle;// 开启系统自动旋转时，设备旋转的角度0/90/270（手机倒置180不会更新）
@property (nonatomic) MNNFaceDetectionReport *lastReport;
@property (nonatomic) UIImage *mCaptureImage;
@property (nonatomic) BOOL isDetecting;
@property (nonatomic) UIImage *userImage;
@property (nonatomic) MBProgressHUD *uploadingHUD;

@end

@implementation DynamicLiveDetectViewController

- (BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    MNNFaceDetectorCreateConfig *createConfig = [[MNNFaceDetectorCreateConfig alloc] init];
    createConfig.detectMode = MNN_FACE_DETECT_MODE_VIDEO;
    [MNNFaceDetector createInstanceAsync:createConfig callback:^(NSError *error, MNNFaceDetector *net) {
        self.faceDetector = net;
    }];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadVideoData:) name:@"uploadVideoData" object:nil];
    self.faceAction = [self.faceActions firstObject];
    
    self.actionCount = 0;
    
    // pull获取设备陀螺仪数据（和系统自动旋转是否打开无关）
    self.motionManager = [[CMMotionManager alloc] init];
    if ([self.motionManager isDeviceMotionAvailable]) {
        [self.motionManager startDeviceMotionUpdates];
    }
    
    [self loadSubviews];
    [self addObserver];
    //加载gif
    [self loadCaptureGif];
    //重置曝光值为0
    [self.mCamera setExposureValue:0];
    //采集格式
    self.mCamera.captureFormat = kCVPixelFormatType_32BGRA;
    //前置摄像头
    [self.mCamera changeCameraInputDeviceisFront:YES];
    [self.view addSubview:self.uploadingHUD];
}

- (MBProgressHUD *)uploadingHUD {
    if (!_uploadingHUD) {
        _uploadingHUD = [[MBProgressHUD alloc] initWithView:self.view];
        _uploadingHUD.label.text = @"验证中，请稍后";
        _uploadingHUD.mode = MBProgressHUDModeDeterminate;
    }
    return _uploadingHUD;
}


- (void)uploadVideoData:(NSNotification *)notification {
    [self.uploadingHUD showAnimated:YES];
    NSLog(@"videoFile:%@ %@",notification.object,notification.userInfo);
    NSString *filePath = notification.object;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.mCamera startCapture];
    if (self.isCaptureVedio) {
        [self.mCamera startRecord];
    }
    [self.avartImg startGif];
    
    [self performSelector:@selector(startTimer) withObject:nil afterDelay:3];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.mCamera resetFocusAndExposureModes];
    [self.mCamera stopCapture];
    [self.avartImg stopGif];
    [self stopTimer];
}

- (void)loadSubviews{
    [self.view addSubview:self.renderView];
    [self.view addSubview:self.progressView];
    [self.view addSubview:self.maskView];
    [self.view addSubview:self.avartImg];
    [self.view addSubview:self.tipLab];
    [self.view addSubview:self.countDownLabel];
    [self.countDownLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.tipLab);
        make.centerY.equalTo(self.tipLab).mas_offset(40);
        make.width.mas_equalTo(150);
        make.height.mas_equalTo(24);
    }];
//    [self.countDownTimer fire];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchScreenAction:)];
    [self.maskView addGestureRecognizer:tap];
}

- (NSBundle *)DLD_bundle {
    NSString *bundle = [[NSBundle mainBundle] pathForResource:@"DynamicLiveDetect" ofType:@"bundle"];
    return [NSBundle bundleWithPath:bundle];
}
- (void)loadCaptureGif{
    NSString *path = [[self DLD_bundle] pathForResource:@"face_capture" ofType:@"gif"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    self.avartImg.gifData = data;
}


#pragma mark - action
- (void)touchScreenAction:(UITapGestureRecognizer *)tap {
    if (tap.view == self.maskView) {
        CGPoint center = [tap locationInView:self.maskView];
        // 聚焦 + 曝光
        self.mCamera.focusPoint = CGPointMake(center.y/self.view.bounds.size.height, self.mCamera.isFrontCamera ? center.x/self.view.bounds.size.width : 1 - center.x/self.view.bounds.size.width);
        self.mCamera.exposurePoint = CGPointMake(center.y/self.view.bounds.size.height, self.mCamera.isFrontCamera ? center.x/self.view.bounds.size.width : 1 - center.x/self.view.bounds.size.width);
    }
}

//- (MNNFaceDetector *)faceDetector {
//    if (!_faceDetector) {
//        MNNFaceDetectorCreateConfig *createConfig = [[MNNFaceDetectorCreateConfig alloc] init];
//        createConfig.detectMode = MNN_FACE_DETECT_MODE_VIDEO;
//        [MNNFaceDetector createInstanceAsync:createConfig callback:^(NSError *error, MNNFaceDetector *net) {
//            self->_faceDetector = net;
//        }];
//    }
//    return _faceDetector;
//}

- (UIImage *)mCaptureImage {
    if (!_mCaptureImage) {
        _mCaptureImage = [[UIImage alloc] init];
    }
    return _mCaptureImage;
}

- (NSDictionary *)faceAction {
    if (!_faceAction) {
        _faceAction = [NSDictionary new];
    }
    return _faceAction;
}

- (void)startTimer {
    self.isDetecting = YES;
    self.countDownIndex = 8;
    [self.countDownTimer fire];
    [self.countDownLabel setHidden:NO];
    
}

- (void)stopTimer {
    [self.countDownTimer invalidate];
    self.countDownTimer = nil;
    if (self.isCaptureVedio) {
        [self.mCamera stopRecord];
    }
}

- (void)pauseTimer {
    self.actionCount ++;
    self.countDownIndex = 8;
}

- (void)countDown {
    if (self.countDownIndex >= 0) {
        self.countDownLabel.text = [NSString stringWithFormat:@"%@ 剩余%ld秒",[self.faceAction objectForKey:@"actionTip"],self.countDownIndex];
        self.countDownIndex --;
    }
    else {
        self.countDownIndex = 0;
        //检测超时，退出检测，返回上一页
        UIImage *avartImage = [UIView xy_captureWithView:self.renderView];
        self.userImage = avartImage;
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - getter/setter
-(FUCamera *)mCamera {
    if (!_mCamera) {
        _mCamera = [[FUCamera alloc] initWithCameraPosition:AVCaptureDevicePositionFront captureFormat:kCVPixelFormatType_32BGRA];
//        _mCamera = [[FUCamera alloc] init];
        _mCamera.delegate = self ;
    }
    return _mCamera ;
}

- (UIVisualEffectView *)gussianBlurView {
    if (!_gussianBlurView) {
        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular];
        
        _gussianBlurView = [[UIVisualEffectView alloc] initWithEffect:effect];
        _gussianBlurView.alpha = 0.94;
        _gussianBlurView.frame = UIScreen.mainScreen.bounds;
    }
    return _gussianBlurView;
}

- (FUOpenGLView *)renderView{
    if (!_renderView) {
        _renderView = [[FUOpenGLView alloc]initWithFrame:CGRectMake(0, 0, KScreenW, KScreenH)];
    }
    return _renderView;
}

- (XYDashLineProgress *)progressView{
    if (!_progressView) {
        _progressView = [[XYDashLineProgress alloc]initWithFrame:CGRectMake(0, kRoundTop - 15, (kRoundRadius+15)*2,  (kRoundRadius+15)*2)];
        _progressView.centerX = self.view.centerX;
        _progressView.trackColor = [UIColor colorWithWhite:1 alpha:1];
    }
    return _progressView;
}

- (UIView *)maskView{
    if (!_maskView) {
        _maskView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, KScreenW, KScreenH)];
        _maskView.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.7];
        //贝塞尔曲线 画一个带有圆角的矩形
        UIBezierPath *bpath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, KScreenW, KScreenH) cornerRadius:0];
        //贝塞尔曲线 画一个圆形
        [bpath appendPath:[UIBezierPath bezierPathWithArcCenter:CGPointMake(_maskView.centerX, kRoundTop+kRoundRadius) radius:kRoundRadius startAngle:0 endAngle:2*M_PI clockwise:NO]];
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = bpath.CGPath;
        _maskView.layer.mask = shapeLayer;
    }
    return _maskView;
}

- (UIImageView *)avartImg{
    if (!_avartImg) {
        _avartImg = [[LLGifImageView alloc]initWithFrame:CGRectMake(0, 0, 145, 198)];
        _avartImg.center = _progressView.center;
//        _avartImg.image = [UIImage imageNamed:@"imagepicker_postion"];
        _avartImg.image = [UIImage imageNamed:"imagepicker_postion" inBundle:[self DLD_bundle] compatibleWithTraitCollection:nil];
    }
    return _avartImg;
}

- (UILabel *)tipLab{
    if (!_tipLab) {
        _tipLab = [[UILabel alloc]init];
        _tipLab.X = 0;
        _tipLab.Y = CGRectGetMaxY(_progressView.frame) + 10;
        _tipLab.width = KScreenW;
        _tipLab.height = 20;
        _tipLab.textAlignment = NSTextAlignmentCenter;
        _tipLab.textColor = [UIColor whiteColor];
        _tipLab.font = [UIFont systemFontOfSize:14.f];
        _tipLab.text = @"请将面部正对圆圈中心区域";
    }
    return _tipLab;
}

- (UILabel *)countDownLabel {
    if (!_countDownLabel) {
        _countDownLabel = [[UILabel alloc]init];
        _countDownLabel.textAlignment = NSTextAlignmentCenter;
        _countDownLabel.textColor = [UIColor whiteColor];
        _countDownLabel.font = [UIFont systemFontOfSize:19];
        _countDownLabel.text = @"即将开始检测";
    }
    return _countDownLabel;
}

- (NSTimer *)countDownTimer {
    if (!_countDownTimer) {
        _countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDown) userInfo:nil repeats:YES];
    }
    return _countDownTimer;
}

#pragma mark --- FUCameraDelegate
- (void)didOutputVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    [self.renderView displayPixelBuffer:pixelBuffer withLandmarks:NULL count:0];
    
    NSDictionary *angleDic = [self calculateInAndOutAngle];
    float inAngle = [angleDic[@"inAngle"] floatValue];
    float outAngle = [angleDic[@"outAngle"] floatValue];
    
    MNNFaceDetectConfig detectConfig = EYE_BLINK|MOUTH_AH|HEAD_YAW|HEAD_PITCH|BROW_JUMP;
    
    NSError *error = nil;
    NSArray<MNNFaceDetectionReport *> *detectResult = [self.faceDetector inferenceWithPixelBuffer:CMSampleBufferGetImageBuffer(sampleBuffer) config:detectConfig angle:inAngle outAngle:outAngle flipType:FLIP_NONE error:&error];
    if (error) {
            NSLog(@"%@", error.localizedDescription);
            return;
    }
    if (detectResult && detectResult.count > 0) {
        MNNFaceDetectionReport *report = [detectResult firstObject];
        self.lastReport = report;
        if (self.isDetecting) {
            if (report.faceAction == [[self.faceAction objectForKey:@"actionCode"] integerValue]) {
                self.isDetecting = NO;
                //检测到相关动作，暂停计时器
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIImage *avartImage = [UIView xy_captureWithView:self.renderView];
                    self.userImage = avartImage;
                    [self.countDownTimer setFireDate:[NSDate distantFuture]];
                    NSData *imageData = UIImageJPEGRepresentation(avartImage, 1);
                    NSString *base64Str = [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
                    if (self.delegate && [self.delegate respondsToSelector:@selector(DynamicLiveDetectWithImageBase64String:)]) {
                        [self.delegate DynamicLiveDetectWithImageBase64String:base64Str];
                    }
                    [self dismissViewControllerAnimated:YES completion:nil];
                });
            }
        }
    }
}

- (NSDictionary*)calculateInAndOutAngle {
    
    double degree = [self rotateDegreeFromDeviceMotion];
    //可以根据不同角度检测处理，这里只检测四个角度的改变
    int rotateDegree = (((int)degree + 45) / 90 * 90) % 360;// 0/90/180/270

    //    NSLog(@"物理设备旋转角度: %d", rotateDegree);
    //    NSLog(@"自动旋转j角度: %d", _deviecAutoRotateAngle);
        
    /**
    如果自动旋转角度为0，无论有没有打开自动旋转，都当做关闭自动旋转处理
    如果自动旋转角度不为0，则一定是打开的自动旋转
    */
    int inAngle = 0;
    int outAngle = 0;
    if (self.deviecAutoRotateAngle==0) {
        inAngle = rotateDegree;
        outAngle = rotateDegree;
    }
    /**
    自动旋转打开时，手机旋转180标题栏不会翻转，保留上一个的状态
    */
    else if (rotateDegree==180) {
            
        if (self.deviecAutoRotateAngle==90) {
            inAngle = 90;
            outAngle = 90;
        }else if (_deviecAutoRotateAngle==270) {
            inAngle = 270;
            outAngle = 270;
        }
            
    } else {
        inAngle = 0;
        outAngle = 0;
    }
    
    return @{@"inAngle":@(inAngle), @"outAngle":@(outAngle)};
}

// 根据陀螺仪数据计算的设备旋转角度（和系统自动旋转是否打开无关）
- (double)rotateDegreeFromDeviceMotion {
    
    double gravityX = self.motionManager .deviceMotion.gravity.x;
    double gravityY = self.motionManager .deviceMotion.gravity.y;
    //double gravityZ = self.motionManager .deviceMotion.gravity.z;
    // 手机顺时针旋转的角度 0-360
    double xyTheta = atan2(gravityX, -gravityY) / M_PI * 180.0;
    if (gravityX<0) {
        xyTheta = 360+xyTheta;
    }
    
    return xyTheta;
}


#pragma mark --- Observer
- (void)addObserver{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeFaceLogin) name:@"k_close_face_login" object:NULL];
}

- (void)willResignActive
{
    if (self.navigationController.visibleViewController == self) {
        [self.countDownTimer invalidate];
        self.countDownTimer = nil;
    }
}

- (void)didBecomeActive
{
    if (self.navigationController.visibleViewController == self) {
        [self startTimer];
    }
}
- (void)closeFaceLogin {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
