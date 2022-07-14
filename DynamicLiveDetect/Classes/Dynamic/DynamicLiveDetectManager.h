//
//  DynamicLiveDetectManager.h
//  FaceScan
//
//  Created by tikpen on 7/11/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^successBlock)(NSString *base64ImgStr);
typedef void (^failureBlock)(NSString *failedMessage);

@protocol LiveDetectDelegate <NSObject>

- (void)liveDetectSuccessBase64Image:(NSString *)base64Str;
- (void)liveDetectFailureBase64Image:(NSString *)base64Str;

@end

@interface DynamicLiveDetectManager : NSObject

@property (nonatomic, weak) id<LiveDetectDelegate> delegate;

- (void)dynamicLiveDetect;

@end

NS_ASSUME_NONNULL_END
