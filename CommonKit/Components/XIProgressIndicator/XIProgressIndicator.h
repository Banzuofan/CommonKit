
//
//  Created by YXLONG on 15/12/14.
//  Copyright © 2015年 yxlong. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, XIProgressIndicatorStyle) {
    ///展示UIActivityIndicatorView样式的指示符
    XIProgressIndicatorActivity,
    ///展示只有黑色背景样式的指示符
    XIProgressIndicatorLoading,
    ///展示黑色背景带有提示信息样式的指示符
    XIProgressIndicatorLoadingInfo,
    ///Toast提示
    XIProgressIndicatorToast
};

///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////
@interface UIView (XIProgressIndicator)

- (void)showActivityIndicatorWithStyle001:(UIActivityIndicatorViewStyle)style;
- (void)hideActivityIndicator001;

- (void)showLoadingIndicatorWithMessage001:(NSString *)message;
- (void)hideLoadingIndicatorWithMessage001;

- (void)showLoadingIndicator001;
- (void)hideLoadingIndicator001;

- (void)showWithMessage001:(NSString *)message;

- (void)clearAllIndicators001;
@end

///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////
@interface XIProgressIndicator : UIView
@property(nonatomic, assign) BOOL showActivityIndicator;
@property(nonatomic, assign) XIProgressIndicatorStyle progressIndicatorStyle;
@property(nonatomic, assign) CGFloat opacity;
@property(nonatomic, strong) UIFont *font;
@property(nonatomic, strong) UIColor *textColor;
@property(nonatomic, strong) NSString *message;
@property(nonatomic, assign) UIActivityIndicatorViewStyle activityIndicatorViewStyle;
@property(nonatomic, assign) NSTimeInterval dismissAfter UI_APPEARANCE_SELECTOR;

+ (instancetype)showActivityIndicatorView:(UIView *)view style:(UIActivityIndicatorViewStyle)style;
+ (instancetype)showIndicatorOnView:(UIView *)view;
+ (instancetype)showIndicatorOnView:(UIView *)view animated:(BOOL)animated;
+ (instancetype)showIndicatorOnView:(UIView *)view message:(NSString *)message;
+ (instancetype)showIndicatorOnView:(UIView *)view message:(NSString *)message animated:(BOOL)animated;
+ (void)alertShowOnView:(UIView *)view message:(NSString *)message;
+ (void)alertShowOnView:(UIView *)view message:(NSString *)message animated:(BOOL)animated;
+ (void)alertShowOnView:(UIView *)view message:(NSString *)message completion:(void(^)(void))completion animated:(BOOL)animated;
+ (void)hideForView:(UIView *)view style:(XIProgressIndicatorStyle)style animated:(BOOL)animated;
+ (void)clearIndicatorsOnView:(UIView *)view;
@end

