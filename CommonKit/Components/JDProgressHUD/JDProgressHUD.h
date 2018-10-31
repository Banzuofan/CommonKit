
//  Created by YXLONG on 2016/12/13.
//  Copyright © 2016年 yxlong. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, JDProgressHUDStyle) {
    ProgressHUDStyleLoading,
    ProgressHUDStyleToast
};

typedef NS_ENUM(NSUInteger, JDToastGravity) {
    ToastGravityTop,
    ToastGravityCenter
};

@interface JDProgressHUD : UIView

+ (void)showProgressHUDOnView:(UIView *)aView
                 toastGravity:(JDToastGravity)toastGravity
                       status:(NSString *)status
                        style:(JDProgressHUDStyle)style
                 dismissAfter:(NSTimeInterval)dismissAfter;

+ (void)showProgressHUDOnView:(UIView *)aView
                       status:(NSString *)status
                        style:(JDProgressHUDStyle)style
                 dismissAfter:(NSTimeInterval)dismissAfter;

+ (void)showStatus:(NSString *)status onView:(UIView *)aView;
+ (void)showToast:(NSString *)message onView:(UIView *)aView dismissAfter:(NSTimeInterval)dismissAfter;
+ (void)showToast:(NSString *)message toastGravity:(JDToastGravity)toastGravity onView:(UIView *)aView dismissAfter:(NSTimeInterval)dismissAfter;

+ (void)showToastFromTop:(NSString *)message
             staticStart:(CGFloat)staticStart
             animatedEnd:(CGFloat)animatedEnd
                  onView:(UIView *)aView
            dismissAfter:(NSTimeInterval)dismissAfter;

/**
 * Remove the pending message in queue or the visible on aView.
 */
+ (void)dismissVisibleProgressHUDsOnView:(UIView *)aView animated:(BOOL)animated;

+ (void)clears;
@end

@interface JDProgressHUD (Designated)
+ (void)showMessage:(NSString *)message;
@end

