
//
//  Created by YXLONG on 15/12/14.
//  Copyright © 2015年 yxlong. All rights reserved.
//

#import "XIProgressIndicator.h"
#import <objc/runtime.h>

#define kFixedIndicatorViewHeight 50
#define kDefaultIndicatorViewWidth 120
#define kDefaultOpacity 0.9
#define kNoMessageViewSideLen 75
#define kSquareStyleSideLen 99
#define kMiniMarginSize 60
#define ScreenPortraitWidth MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)
#define kDefaultRadius 6.0f

@interface UIView (XIProgressIndicatorViewHelper)
@property (nonatomic) CGFloat r_left;
@property (nonatomic) CGFloat r_right;
@property (nonatomic) CGFloat r_width;
@property (nonatomic) CGFloat r_height;
@property (nonatomic) CGSize r_size;
@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@interface UIView (ProcessorIndicatorHelper)
@property(nonatomic, assign) NSInteger indicatorCount;
@property(nonatomic, assign) NSInteger indicatorWithMessageCount;
@end

static void* keyViewIndicatorCount = &keyViewIndicatorCount;
static void* keyViewIndicatorMsgCount = &keyViewIndicatorMsgCount;
@implementation UIView (ProcessorIndicatorHelper)
- (NSInteger)indicatorCount
{
    return [objc_getAssociatedObject(self, keyViewIndicatorCount) integerValue];
}
- (void)setIndicatorCount:(NSInteger)value
{
    [self willChangeValueForKey:@"indicatorCount"];
    objc_setAssociatedObject(self, keyViewIndicatorCount, @(value), OBJC_ASSOCIATION_ASSIGN);
    [self didChangeValueForKey:@"indicatorCount"];
}
- (NSInteger)indicatorWithMessageCount
{
    return [objc_getAssociatedObject(self, keyViewIndicatorMsgCount) integerValue];
}
- (void)setIndicatorWithMessageCount:(NSInteger)value
{
    [self willChangeValueForKey:@"indicatorWithMessageCount"];
    objc_setAssociatedObject(self, keyViewIndicatorMsgCount, @(value), OBJC_ASSOCIATION_ASSIGN);
    [self didChangeValueForKey:@"indicatorWithMessageCount"];
}
@end


//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@interface XIProgressIndicator ()
{
    UIActivityIndicatorView  * activityIndicatorView;
    UILabel * messageLabel;
}
- (instancetype)initWithFrame:(CGRect)frame message:(NSString *)message;
+ (instancetype)showOnView:(UIView *)view
                     style:(XIProgressIndicatorStyle)style
                   message:(NSString *)message
                      font:(UIFont *)font
                 textColor:(UIColor *)textColor
                   opacity:(CGFloat)opacity
     showActivityIndicator:(BOOL)showActivityIndicator
                  animated:(BOOL)animated;
+ (CGSize)getStringSize:(NSString *)str font:(UIFont *)font constranitSize:(CGSize)ConstranitSize;
- (void)adjustViewFrame;
+ (XIProgressIndicator *)findExsitingIndicatorOnView:(UIView *)view style:(XIProgressIndicatorStyle)style;
- (void)startAnimating;
@end


//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
@implementation XIProgressIndicator

bool check_str_empty(NSString *str){
    if(![str isKindOfClass:[NSString class]]){
        return true;
    }
    if(!str||str.length==0){
        return true;
    }
    return false;
}

+ (void)initialize
{
    if (self == [XIProgressIndicator class]) {
        [XIProgressIndicator appearance].dismissAfter = 1.2;
    }
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        self.backgroundColor = [UIColor clearColor];
        self.opacity = kDefaultOpacity;
        self.showActivityIndicator = YES;
        
        messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        messageLabel.font = [UIFont systemFontOfSize:15.0f];
        messageLabel.textAlignment = NSTextAlignmentLeft;
        messageLabel.backgroundColor = [UIColor clearColor];
        messageLabel.textColor = [UIColor whiteColor];
        [self addSubview:messageLabel];
        
        activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        activityIndicatorView.hidesWhenStopped = NO;
        activityIndicatorView.frame = CGRectMake(0, 0, kFixedIndicatorViewHeight, kFixedIndicatorViewHeight);
        [self addSubview:activityIndicatorView];
        [activityIndicatorView startAnimating];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame message:(NSString *)message
{
    if(self = [self initWithFrame:frame]){
        messageLabel.text = message;
        if(check_str_empty(message)){
            activityIndicatorView.r_size = CGSizeMake(kNoMessageViewSideLen, kNoMessageViewSideLen);
            activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
            
            self.r_size = CGSizeMake(kNoMessageViewSideLen, kNoMessageViewSideLen);
        }
        else{
            [self adjustViewFrame];
        }
    }
    return self;
}

- (void)startAnimating
{
    [activityIndicatorView startAnimating];
}

- (void)adjustViewFrame
{
    messageLabel.numberOfLines = 0;
    CGFloat indicatorSizeHeight = kSquareStyleSideLen*2/3;
    
    CGFloat screenWidth = ScreenPortraitWidth;
    if(_showActivityIndicator){
        
        if(activityIndicatorView.activityIndicatorViewStyle!=UIActivityIndicatorViewStyleWhiteLarge){
            activityIndicatorView.activityIndicatorViewStyle=UIActivityIndicatorViewStyleWhiteLarge;
        }
        
        if(!check_str_empty(messageLabel.text)){
            activityIndicatorView.r_size = CGSizeMake(indicatorSizeHeight, indicatorSizeHeight);
            [activityIndicatorView startAnimating];
        }
        else{
            activityIndicatorView.frame = CGRectMake(0, 0, kNoMessageViewSideLen, kNoMessageViewSideLen);
            self.r_size = CGSizeMake(kNoMessageViewSideLen, kNoMessageViewSideLen);
            return;
        }
    }
    else{
        if(!check_str_empty(messageLabel.text)){
            if(activityIndicatorView.isAnimating){
                [activityIndicatorView stopAnimating];
            }
        }
    }
    BOOL needExtendAlongAxisY = NO;
    CGFloat maxPreferredWidth = screenWidth-kMiniMarginSize*2;
    CGFloat defaultPreferredWidth = kSquareStyleSideLen-20;
    CGFloat textWidth;
    CGFloat textHeight;
    CGFloat labelMaxWidth;
    CGFloat lb_px;
    CGSize size = [self getMessageLabelSize:CGSizeMake(maxPreferredWidth, MAXFLOAT)];
    textWidth = size.width;
    textHeight = size.height;
    if(textWidth<defaultPreferredWidth){
        lb_px = kSquareStyleSideLen/2-textWidth/2;
        labelMaxWidth = defaultPreferredWidth;
    }
    else{
        labelMaxWidth = textWidth;
        lb_px = 10+labelMaxWidth/2-textWidth/2;
    }
    
    activityIndicatorView.r_width = labelMaxWidth+20;
    
    if(_showActivityIndicator){
        if(textHeight>kSquareStyleSideLen-indicatorSizeHeight){
            needExtendAlongAxisY = YES;
        }
    }
    else{
        if(textHeight>kFixedIndicatorViewHeight){
            needExtendAlongAxisY = YES;
        }
    }
    if(!_showActivityIndicator){
        CGFloat lb_py = needExtendAlongAxisY? 10:(kFixedIndicatorViewHeight-textHeight)/2;
        messageLabel.frame = CGRectMake(lb_px, lb_py, textWidth, textHeight);
    }
    else{
        messageLabel.frame = CGRectMake(lb_px, indicatorSizeHeight, textWidth, textHeight);
    }
    
    self.r_width = labelMaxWidth+20;
    if(_showActivityIndicator){
        self.r_height = needExtendAlongAxisY? indicatorSizeHeight+textHeight+10:kSquareStyleSideLen;
    }
    else{
        self.r_height = needExtendAlongAxisY? textHeight+20:kFixedIndicatorViewHeight;
    }
}

- (void)setFont:(UIFont *)font
{
    messageLabel.font = font;
    [self adjustViewFrame];
}

- (void)setShowActivityIndicator:(BOOL)showActivityIndicator
{
    _showActivityIndicator = showActivityIndicator;
    if(activityIndicatorView){
        activityIndicatorView.hidden = !showActivityIndicator;
    }
    [self adjustViewFrame];
}

- (void)setMessage:(NSString *)message
{
    messageLabel.text = message;
    [self adjustViewFrame];
}

- (UIFont *)font
{
    return messageLabel.font;
}

- (void)setTextColor:(UIColor *)textColor
{
    messageLabel.textColor = textColor;
}

- (UIColor *)textColor
{
    return messageLabel.textColor;
}

- (void)setOpacity:(CGFloat)opacity
{
    _opacity = opacity;
    if(self.superview){
        [self setNeedsDisplay];
    }
}

- (void)setActivityIndicatorViewStyle:(UIActivityIndicatorViewStyle)activityIndicatorViewStyle
{
    activityIndicatorView.activityIndicatorViewStyle = activityIndicatorViewStyle;
}

#pragma Class Methods

+ (CGSize)getStringSize:(NSString *)str font:(UIFont *)font constranitSize:(CGSize)ConstranitSize
{
    if(check_str_empty(str)){
        return CGSizeZero;
    }
    NSDictionary *attrs = @{NSFontAttributeName : font};
    NSAttributedString* atrString = [[NSAttributedString alloc] initWithString:str attributes:attrs];
    return [atrString boundingRectWithSize:ConstranitSize
                                   options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                   context:nil].size;
}

- (CGSize)getMessageLabelSize:(CGSize)constranitSize
{
    return [[self class] getStringSize:messageLabel.text
                                  font:messageLabel.font
                        constranitSize:constranitSize];
}

////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////

+ (instancetype)showActivityIndicatorView:(UIView *)view style:(UIActivityIndicatorViewStyle)style
{
    XIProgressIndicator *indicatorView = [[self class] showOnView:view
                                                                 style:XIProgressIndicatorActivity
                                                               message:nil
                                                                  font:nil
                                                             textColor:nil
                                                               opacity:0.8
                                                 showActivityIndicator:YES
                                                              animated:YES];
    indicatorView.activityIndicatorViewStyle = style;
    indicatorView.opacity = 0;
    return indicatorView;
}

////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////

+ (instancetype)showIndicatorOnView:(UIView *)view animated:(BOOL)animated
{
    return [[self class] showOnView:view style:XIProgressIndicatorLoading message:nil font:nil textColor:nil opacity:0.8 showActivityIndicator:YES animated:animated];
}

+ (instancetype)showIndicatorOnView:(UIView *)view
{
    return [[self class] showIndicatorOnView:view animated:YES];
}

////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////

+ (instancetype)showIndicatorOnView:(UIView *)view message:(NSString *)message animated:(BOOL)animated
{
    return [[self class] showOnView:view style:XIProgressIndicatorLoadingInfo message:message font:nil textColor:nil opacity:0.8 showActivityIndicator:YES animated:animated];
}

+ (instancetype)showIndicatorOnView:(UIView *)view message:(NSString *)message
{
    return [[self class] showIndicatorOnView:view message:message animated:YES];
}

////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////

+ (void)alertShowOnView:(UIView *)view message:(NSString *)message completion:(void(^)(void))completion animated:(BOOL)animated
{
    XIProgressIndicator *indicator = [[self class] showOnView:view style:XIProgressIndicatorToast
                                                       message:message
                                                          font:nil
                                                     textColor:nil
                                                       opacity:0.8
                                         showActivityIndicator:NO
                                                      animated:animated];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(indicator.dismissAfter * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[self class] hideForView:view style:XIProgressIndicatorToast animated:animated];
        if(completion){
            completion();
        }
    });
}

+ (void)alertShowOnView:(UIView *)view message:(NSString *)message animated:(BOOL)animated
{
    [[self class] alertShowOnView:view message:message completion:nil animated:animated];
}

+ (void)alertShowOnView:(UIView *)view message:(NSString *)message
{
    [[self class] alertShowOnView:view message:message animated:YES];
}

////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////

+ (instancetype)showOnView:(UIView *)view
                     style:(XIProgressIndicatorStyle)style
                   message:(NSString *)message
                      font:(UIFont *)font
                 textColor:(UIColor *)textColor
                   opacity:(CGFloat)opacity
     showActivityIndicator:(BOOL)showActivityIndicator
                  animated:(BOOL)animated
{
    BOOL isResusedView = NO;
    XIProgressIndicator * _indicatorView = [XIProgressIndicator findExsitingIndicatorOnView:view style:style];
    if(_indicatorView){
        isResusedView = YES;
        _indicatorView.message = message;
    }
    else{
        _indicatorView = [[XIProgressIndicator alloc] initWithFrame:CGRectMake(0, 0, kDefaultIndicatorViewWidth, kFixedIndicatorViewHeight) message:message];
        _indicatorView.progressIndicatorStyle = style;
    }
    _indicatorView.showActivityIndicator = showActivityIndicator;
    if(font){
        _indicatorView.font = font;
    }
    if(textColor){
        _indicatorView.textColor = textColor;
    }
    _indicatorView.opacity = opacity;
    _indicatorView.center = CGPointMake(view.bounds.size.width/2, view.bounds.size.height/2);
    _indicatorView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin;
    if(!isResusedView){
        [view addSubview:_indicatorView];
        
        _indicatorView.alpha = 0.0f;
        if(animated)
        {
            if(style==XIProgressIndicatorToast){
                _indicatorView.transform = CGAffineTransformMakeScale(1.2, 1.2);
                [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    _indicatorView.alpha = 1.0f;
                    _indicatorView.transform = CGAffineTransformIdentity;
                } completion:^(BOOL finished) {
                    
                }];
            }
            else{
                if(style==XIProgressIndicatorActivity){
                    [_indicatorView startAnimating];
                }
                [UIView animateWithDuration:.25 animations:^{
                    _indicatorView.alpha = 1.0f;
                }];
            }
        }
        else
        {
            _indicatorView.alpha = 1.0f;
        }
    }
    [view bringSubviewToFront:_indicatorView];
    return _indicatorView;
}

////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////

+ (void) hideForView:(UIView *) view style:(XIProgressIndicatorStyle)style animated:(BOOL) animated
{
    __block XIProgressIndicator *indicatorView = [XIProgressIndicator findExsitingIndicatorOnView:view style:style];
    if(indicatorView){
        if(animated)
        {
            NSTimeInterval delay = 0;
            if(indicatorView.progressIndicatorStyle==XIProgressIndicatorActivity){
                delay = 1;
            }
            [UIView animateWithDuration:.25 delay:delay options:UIViewAnimationOptionCurveEaseInOut animations:^{
                indicatorView.alpha = 0.0f;
            } completion:^(BOOL finished) {
                [indicatorView removeFromSuperview];
                indicatorView = nil;
            }];
        }
        else
        {
            [indicatorView removeFromSuperview];
            indicatorView = nil;
        }
    }
}

+ (void)clearIndicatorsOnView:(UIView *)view
{
    if(view==nil){
        return;
    }
    for(UIView *elem in view.subviews){
        if([elem isKindOfClass:[XIProgressIndicator class]]){
            [elem removeFromSuperview];
        }
    }
}

+ (XIProgressIndicator *)findExsitingIndicatorOnView:(UIView *)view style:(XIProgressIndicatorStyle)style
{
    XIProgressIndicator *viewToRemove = nil;
    for (UIView *v in [view subviews]) {
        if ([v isKindOfClass:[XIProgressIndicator class]]) {
            XIProgressIndicator *fv = (XIProgressIndicator *)v;
            if(fv.progressIndicatorStyle==style){
                viewToRemove = fv;
                break;
            }
        }
    }
    return viewToRemove;
}

#pragma mark-- Drawing

- (void)drawRect:(CGRect)rect {
    
    CGRect boxRect = self.bounds;
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:boxRect cornerRadius:kDefaultRadius];
    [[UIColor colorWithWhite:0 alpha:self.opacity] setFill];
    [path fill];
}
@end

////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////

@implementation UIView (XIProgressIndicatorViewHelper)

- (CGFloat)r_left {
    return self.frame.origin.x;
}

- (void)setR_left:(CGFloat)x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)r_right {
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setR_right:(CGFloat)right {
    CGRect frame = self.frame;
    frame.origin.x = right - frame.size.width;
    self.frame = frame;
}

- (CGFloat)r_width {
    return self.frame.size.width;
}

- (void)setR_width:(CGFloat)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)r_height {
    return self.frame.size.height;
}

- (void)setR_height:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGSize)r_size {
    return self.frame.size;
}

- (void)setR_size:(CGSize)size {
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}
@end

///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////

@implementation UIView (XIProgressIndicator)
//
// XIProgressIndicatorActivity
//
- (void)showActivityIndicatorWithStyle001:(UIActivityIndicatorViewStyle)style
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        [XIProgressIndicator showActivityIndicatorView:self style:style];
    });
}

- (void)hideActivityIndicator001
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [XIProgressIndicator hideForView:self style:XIProgressIndicatorActivity animated:YES];
    });
}
//
// XIProgressIndicatorLoadingInfo
//
- (void)showLoadingIndicatorWithMessage001:(NSString *)message
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.indicatorWithMessageCount++;
        [XIProgressIndicator showIndicatorOnView:self message:message];
    });
}

- (void)hideLoadingIndicatorWithMessage001
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.indicatorWithMessageCount>0){
            self.indicatorWithMessageCount--;
        }
        if(self.indicatorWithMessageCount==0){
            [XIProgressIndicator hideForView:self style:XIProgressIndicatorLoadingInfo animated:YES];
        }
    });
}
//
// XIProgressIndicatorLoading
//
- (void)showLoadingIndicator001
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.indicatorCount++;
        [XIProgressIndicator showIndicatorOnView:self animated:YES];
    });
}

- (void)hideLoadingIndicator001
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.indicatorCount>0){
            self.indicatorCount--;
        }
        if(self.indicatorCount==0){
            [XIProgressIndicator hideForView:self style:XIProgressIndicatorLoading animated:YES];
        }
    });
}

//
// XIProgressIndicatorToast
//
- (void)showWithMessage001:(NSString *)message
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [XIProgressIndicator alertShowOnView:self message:message completion:^{
            
        } animated:YES];
    });
}

- (void)clearAllIndicators001
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.indicatorCount = 0;
        [XIProgressIndicator clearIndicatorsOnView:self];
    });
}
@end
