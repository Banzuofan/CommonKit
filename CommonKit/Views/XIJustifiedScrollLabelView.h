//
//  JRScrollJustifiedLabelView.h
//  JDStock
//
//  Created by YXLONG on 16/3/31.
//  Copyright © 2016年 jdjr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

@interface XIJustifiedLabelView : UIView
@property(nonatomic, strong) NSString *text;
@property(nonatomic, strong) NSMutableAttributedString *attributedText;
@property(nonatomic, strong) UIFont *font;
@property(nonatomic, strong) UIColor *textColor;
@end

@interface XIJustifiedScrollLabelView : UIView
@property(nonatomic, copy) NSString *text;
@property(nonatomic, strong) UIColor *textColor;
@property(nonatomic, strong) UIFont *font;
@end
