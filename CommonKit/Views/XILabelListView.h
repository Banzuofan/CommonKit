
//
//  Created by YXLONG on 2017/4/28.
//  Copyright © 2017年 yxlong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XILabelListView : UITableView
@property(nonatomic, strong) UIFont * _Nullable labelFont;
@property(nonatomic, strong) UIColor * _Nullable labelColor;
@property(nonatomic, assign) BOOL showIndex;

- (void)setLabels:(NSArray<NSString *>*_Nullable)arr;
@end
