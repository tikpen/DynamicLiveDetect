//
//  DynamicLiveDetectViewController.h
//  FRAS
//
//  Created by tikpen on 5/11/21.
//  Copyright © 2021 WYFeng. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DynamicLiveDetectDelegate <NSObject>

- (void)DynamicLiveDetectWithImageBase64String:(NSString *)imgBase64Str;

@end

@interface DynamicLiveDetectViewController : UIViewController

@property (nonatomic) NSArray *faceActions;

@property (nonatomic) BOOL isCaptureVedio;

@property (nonatomic, weak) id<DynamicLiveDetectDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
