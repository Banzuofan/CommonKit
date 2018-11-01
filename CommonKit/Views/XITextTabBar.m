
//
//  Created by YXLONG on 2017/9/10.
//  Copyright © 2017年 yxlong. All rights reserved.
//

#import "XITextTabBar.h"

#define kDefaultBarHeight 34
#define kButtonBaseTag 100

typedef UIButton JDTextTabBarItem;

@interface XITextTabBar ()
{
    NSMutableArray *_barItems;
    NSMutableDictionary *_colorSettings;
}
@end

@implementation XITextTabBar

- (instancetype)initWithItems:(NSArray<NSString *> *)items
{
    if(self=[super initWithFrame:CGRectZero]){
        self.userInteractionEnabled = YES;
        _barItems = [NSMutableArray arrayWithCapacity:5];
        _colorSettings = [NSMutableDictionary dictionaryWithCapacity:5];
        
        [self commonInit];
        
        for(int i=0;i<items.count;i++){
            JDTextTabBarItem *item = [JDTextTabBarItem buttonWithType:UIButtonTypeCustom];
            item.tag = kButtonBaseTag+i;
            item.titleLabel.font = _itemTextFont;
            [item setTitleColor:_colorSettings[@(UIControlStateNormal)] forState:UIControlStateNormal];
            [item setTitleColor:_colorSettings[@(UIControlStateSelected)] forState:UIControlStateSelected];
            [item setTitleColor:_colorSettings[@(UIControlStateSelected)] forState:UIControlStateHighlighted];
            [item setTitle:items[i] forState:UIControlStateNormal];
            [_barItems addObject:item];
            [self addSubview:item];
            [item addTarget:self action:@selector(buttonActions:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        [self layoutBarItems];
    }
    return self;
}

- (void)buttonActions:(UIButton *)sender
{
    NSInteger tag = sender.tag-kButtonBaseTag;
    if(_selectedIndex==tag){
        return;
    }
    _selectedIndex = tag;
    for(int i=0;i<_barItems.count;i++){
        JDTextTabBarItem *item = _barItems[i];
        item.selected = (_selectedIndex==(item.tag-kButtonBaseTag));
    }
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)commonInit
{
    _itemSpace = 5;
    _itemTextFont = [UIFont systemFontOfSize:14];
    _selectedIndex = 0;
    
    [_colorSettings setObject:[UIColor lightGrayColor] forKey:@(UIControlStateNormal)];
    [_colorSettings setObject:[UIColor blackColor] forKey:@(UIControlStateSelected)];
}

- (void)setItemTextFont:(UIFont *)itemTextFont
{
    _itemTextFont = itemTextFont;
    [self layoutBarItems];
}

- (void)setItemSpace:(CGFloat)itemSpace
{
    _itemSpace = itemSpace;
    [self layoutBarItems];
}

- (void)setItemTitleColor:(UIColor *)color forSate:(UIControlState)state
{
    if(color!=nil){
        [_colorSettings setObject:color forKey:@(state)];
    }
    [self layoutBarItems];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
    _selectedIndex = selectedIndex;
    [self layoutBarItems];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self layoutBarItems];
}

- (void)layoutBarItems
{
    if(_barItems.count==0) return;
    
    JDTextTabBarItem *lastItem = nil;
    for(int i=0;i<_barItems.count;i++){
        JDTextTabBarItem *item = _barItems[i];
        item.selected = (_selectedIndex==(item.tag-kButtonBaseTag));
        item.titleLabel.font = _itemTextFont;
        [item setTitleColor:_colorSettings[@(UIControlStateNormal)] forState:UIControlStateNormal];
        [item setTitleColor:_colorSettings[@(UIControlStateSelected)] forState:UIControlStateSelected];
        [item setTitleColor:_colorSettings[@(UIControlStateSelected)] forState:UIControlStateHighlighted];
        
        [item sizeToFit];
        
        if(!lastItem){
            item.frame = CGRectMake(0, 0, CGRectGetWidth(item.frame), CGRectGetHeight(item.frame));
        }
        else{
            item.frame = CGRectMake(CGRectGetMaxX(lastItem.frame)+_itemSpace, 0, CGRectGetWidth(item.frame), CGRectGetHeight(item.frame));
        }
        
        lastItem = item;
    }
    
    CGRect r = self.frame;
    r.size.width = CGRectGetMaxX(lastItem.frame);
    r.size.height = CGRectGetMaxY(lastItem.frame);
    self.frame = r;
}

@end
