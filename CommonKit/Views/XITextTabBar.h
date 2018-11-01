
//
//  Created by YXLONG on 2017/9/10.
//  Copyright © 2017年 yxlong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XITextTabBar : UIControl
@property(nonatomic, strong) UIFont *itemTextFont;
@property(nonatomic, assign) CGFloat itemSpace;
@property(nonatomic, assign) NSUInteger selectedIndex;

- (instancetype)initWithItems:(NSArray<NSString *> *)items;
- (void)setItemTitleColor:(UIColor *)color forSate:(UIControlState)state;
@end
