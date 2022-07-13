#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "UIView+XYCapture.h"
#import "UIView+ZPFrame.h"
#import "DynamicLiveDetectManager.h"
#import "DynamicLiveDetectViewController.h"
#import "FUCamera.h"
#import "FUImageHelper.h"
#import "FUMusicPlayer.h"
#import "FUOpenGLView.h"
#import "FUVideoReader.h"
#import "WCLRecordEncoder.h"
#import "LLGifImageView.h"
#import "XYDashLineProgress.h"

FOUNDATION_EXPORT double DynamicLiveDetectVersionNumber;
FOUNDATION_EXPORT const unsigned char DynamicLiveDetectVersionString[];

