
//
//  Created by YXLONG on 2018/5/24.
//  Copyright © 2018年 yxlong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JKGradientButton : UIButton
{
@protected
    CAGradientLayer *gradientLayer;
}
@property(nullable, copy) NSArray *colors;
@property(nullable, copy) NSArray<NSNumber *> *locations;
@property CGPoint startPoint;
@property CGPoint endPoint;
@property(nonatomic, assign) CGFloat cornerRadius;
@end
