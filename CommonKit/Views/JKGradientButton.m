
//
//  Created by YXLONG on 2018/5/24.
//  Copyright © 2018年 yxlong. All rights reserved.
//

#import "JKGradientButton.h"

@implementation JKGradientButton

+ (instancetype)buttonWithType:(UIButtonType)buttonType
{
    JKGradientButton *_btn = [[JKGradientButton alloc] initWithFrame:CGRectZero];
    return _btn;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self=[super initWithFrame:frame]){
        gradientLayer =  [CAGradientLayer layer];
        gradientLayer.startPoint = CGPointMake(0, 0);
        gradientLayer.endPoint = CGPointMake(0, 1);
        gradientLayer.locations = @[@(0.1),@(0.9)];
        [self.layer addSublayer:gradientLayer];
    }
    return self;
}

- (NSArray *)colors
{
    return gradientLayer.colors;
}

- (void)setColors:(NSArray *)colors
{
    [gradientLayer setColors:colors];
}

- (NSArray<NSNumber *> *)locations
{
    return gradientLayer.locations;
}

- (void)setLocations:(NSArray<NSNumber *> *)locations
{
    if(gradientLayer){
        gradientLayer.locations = locations;
    }
}

- (CGPoint)startPoint
{
    return gradientLayer.startPoint;
}

- (void)setStartPoint:(CGPoint)startPoint
{
    gradientLayer.startPoint = startPoint;
}

- (CGPoint)endPoint
{
    return gradientLayer.endPoint;
}

- (void)setEndPoint:(CGPoint)endPoint
{
    gradientLayer.endPoint = endPoint;
}

- (void)setCornerRadius:(CGFloat)cornerRadius
{
    _cornerRadius = cornerRadius;
    if(gradientLayer){
        gradientLayer.cornerRadius = cornerRadius;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    gradientLayer.frame = self.bounds;
}

@end
