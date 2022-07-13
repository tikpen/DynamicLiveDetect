//
//  DynamicLiveDetectManager.m
//  FaceScan
//
//  Created by tikpen on 7/11/22.
//

#import "DynamicLiveDetectManager.h"
#import <UIKit/UIKit.h>
#import "DynamicLiveDetectViewController.h"

@interface DynamicLiveDetectManager()<DynamicLiveDetectDelegate>

@end

@implementation DynamicLiveDetectManager

- (void)dynamicLiveDetect{
    NSArray *faceActions = @[@{@"actionCode":@4,@"actionName":@"张嘴",@"actionTip":@"请张嘴"}];
    DynamicLiveDetectViewController *vc = [[DynamicLiveDetectViewController alloc]init];
    vc.delegate = self;
    vc.faceActions = faceActions;
    vc.isCaptureVedio = NO;
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    
    UINavigationController *nav = [self getCurrentUIVC].navigationController;
    [nav presentViewController:vc animated:YES completion:nil];
}

- (void)DynamicLiveDetectWithImageBase64String:(NSString *)imgBase64Str{
    if (self.delegate && [self.delegate respondsToSelector:@selector(liveDetectBase64Image:)]) {
        [self.delegate liveDetectBase64Image:imgBase64Str];
    }
}


-(UIViewController *)getCurrentVC{
    UIViewController *result = nil;
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    if (window.subviews.count > 0) {
        UIView *frontView = [[window subviews] objectAtIndex:0];
        id nextResponder = [frontView nextResponder];
        
        if ([nextResponder isKindOfClass:[UIViewController class]])
            result = nextResponder;
        else
            result = window.rootViewController;
        
        return result;
    }
    return nil;
}

-(UIViewController *)getCurrentUIVC
{
    UIViewController* currentViewController = [self getCurrentVC];
    BOOL runLoopFind = YES;
    while (runLoopFind) {
        if (currentViewController.presentedViewController) {
            currentViewController = currentViewController.presentedViewController;
        } else if ([currentViewController isKindOfClass:[UINavigationController class]]) {
            
            UINavigationController* navigationController = (UINavigationController* )currentViewController;
            currentViewController = [navigationController.childViewControllers lastObject];
            
        } else if ([currentViewController isKindOfClass:[UITabBarController class]]) {
            
            UITabBarController* tabBarController = (UITabBarController* )currentViewController;
            currentViewController = tabBarController.selectedViewController;
        } else {
            
            NSUInteger childViewControllerCount = currentViewController.childViewControllers.count;
            if (childViewControllerCount > 0) {
                
                currentViewController = currentViewController.childViewControllers.lastObject;
                
                return currentViewController;
            } else {
                
                return currentViewController;
            }
        }
        
    }
    return currentViewController;
}


- (void)dealloc {
    NSLog(@"--DynamicLiveDetectManager dealloc--");
}
@end
