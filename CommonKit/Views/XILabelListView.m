
//
//  Created by YXLONG on 2017/4/28.
//  Copyright © 2017年 yxlong. All rights reserved.
//

#import "XILabelListView.h"

//!-- private classes
@interface XIBaseLabelListCell : UITableViewCell
{
@protected
    NSMutableArray *contraintsArr;
    UILabel *_contentLabel;
    NSString *_text;
}
@property(nonatomic, strong) UIFont *labelFont;
@property(nonatomic, strong) UIColor *labelColor;
@property(nonatomic, strong, readonly) UILabel *contentLabel;
@property(nonatomic, strong) NSString *text;

- (CGSize)constraintsSize;
+ (NSAttributedString *)makeRichText:(NSString *)text font:(UIFont *)font color:(UIColor *)color;
+ (CGSize)getSize:(NSAttributedString *)aStr withConstraints:(CGSize)size;
@end


@interface XIIndexLabelListCell : XIBaseLabelListCell
@property(nonatomic, assign) NSInteger index;
@end

@interface XILabelListCell : XIBaseLabelListCell
@end

//!--class extension
@interface XILabelListView ()<UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray *dataSourceArr;
}
@end

@implementation XILabelListView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self=[super initWithFrame:frame style:style];
    if(self){
        self.backgroundColor = [UIColor clearColor];
        self.allowsSelection = NO;
        self.delegate = self;
        self.dataSource = self;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.scrollEnabled = NO;
        
        dataSourceArr = @[].mutableCopy;
    }
    return self;
}

- (void)setLabels:(NSArray<NSString *>*)arr
{
    [dataSourceArr removeAllObjects];
    if(arr){
        [dataSourceArr addObjectsFromArray:arr];
    }
    [self reloadData];
}

- (void)setShowIndex:(BOOL)showIndex
{
    _showIndex = showIndex;
    
    [self reloadData];
}

- (UIColor *)labelColor
{
    if(_labelColor){
        return _labelColor;
    }
    return [UIColor blackColor];
}

- (UIFont *)labelFont
{
    if(_labelFont){
        return _labelFont;
    }
    return [UIFont systemFontOfSize:15];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataSourceArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *label = dataSourceArr[indexPath.row];
    if(label.length>0){
        CGSize indexSize = CGSizeZero;
        if(_showIndex){
            NSString *indexPrefix = [NSString stringWithFormat:@"%@.", @(indexPath.row+1)];
            indexSize = [XILabelListCell getSize:[XILabelListCell makeRichText:indexPrefix font:[self labelFont] color:[self labelColor]]
                                        withConstraints:CGSizeMake(tableView.frame.size.width, MAXFLOAT)];
        }
        else{
            
        }
        
        CGSize size = [XILabelListCell getSize:[XILabelListCell makeRichText:label font:[self labelFont] color:[self labelColor]]
                               withConstraints:CGSizeMake(tableView.frame.size.width-indexSize.width, MAXFLOAT)];
        return size.height+6;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellID = [NSString stringWithFormat:@"Cell_%@", @(_showIndex)];
    XIBaseLabelListCell *cell = (XIBaseLabelListCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
    if(!cell){
        if(_showIndex){
            cell = [[XIIndexLabelListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        }
        else{
            cell = [[XILabelListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        }
    }

    cell.labelColor = self.labelColor;
    cell.labelFont = self.labelFont;
    
    if(_showIndex){
        XIIndexLabelListCell *icell = (XIIndexLabelListCell *)cell;
        icell.index = indexPath.row+1;
    }
    
    NSString *label = dataSourceArr[indexPath.row];
    cell.text = label;

    return cell;
}

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(UIViewNoIntrinsicMetric, self.contentSize.height);
}

@end

@implementation XIBaseLabelListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier
{
    if(self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        
        contraintsArr = [NSMutableArray array];
        
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (UIColor *)labelColor
{
    if(_labelColor){
        return _labelColor;
    }
    return [UIColor blackColor];
}

- (UIFont *)labelFont
{
    if(_labelFont){
        return _labelFont;
    }
    return [UIFont systemFontOfSize:15];
}

- (CGSize)constraintsSize
{
    return CGSizeMake(self.frame.size.width, MAXFLOAT);
}

+ (NSAttributedString *)makeRichText:(NSString *)text font:(UIFont *)font color:(UIColor *)color
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:5];
    NSDictionary *attrs = @{NSFontAttributeName:font,
                            NSForegroundColorAttributeName:color,
                            NSParagraphStyleAttributeName:paragraphStyle};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attrs];
}

+ (CGSize)getSize:(NSAttributedString *)aStr withConstraints:(CGSize)size
{
    if(!aStr) return CGSizeZero;
    CGSize aSize = [aStr boundingRectWithSize:size
                                      options:NSStringDrawingUsesLineFragmentOrigin
                                      context:nil].size;
    return CGSizeMake(round(aSize.width), round(aSize.height*10/10)+1);
}

@end

@implementation XILabelListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier
{
    if(self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        
        
        
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _contentLabel.numberOfLines = 0;
        _contentLabel.textColor = self.labelColor;
        _contentLabel.font = self.labelFont;
        [self.contentView addSubview:_contentLabel];
        _contentLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [_contentLabel setContentHuggingPriority:751 forAxis:0];
        [_contentLabel setContentHuggingPriority:751 forAxis:1];
    }
    return self;
}

- (void)setText:(NSString *)text
{
    _text = text;
    
    NSAttributedString *atr = [XILabelListCell makeRichText:text font:self.labelFont color:self.labelColor];
    _contentLabel.attributedText = atr;
    
    [self setNeedsUpdateConstraints];
}

- (void)updateConstraints
{
    [super updateConstraints];
    
    if(_contentLabel.attributedText.string.length>0){
        
        _contentLabel.preferredMaxLayoutWidth = self.constraintsSize.width;
        
        if(contraintsArr){
            [NSLayoutConstraint deactivateConstraints:contraintsArr];
            [contraintsArr removeAllObjects];
        }
        
        if(!contraintsArr){
            contraintsArr = [NSMutableArray array];
        }
        
        [contraintsArr addObjectsFromArray:@[[NSLayoutConstraint constraintWithItem:_contentLabel
                                                                          attribute:NSLayoutAttributeLeft
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self.contentView
                                                                          attribute:NSLayoutAttributeLeft
                                                                         multiplier:1
                                                                           constant:0],
                                             [NSLayoutConstraint constraintWithItem:_contentLabel
                                                                          attribute:NSLayoutAttributeTop
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self.contentView
                                                                          attribute:NSLayoutAttributeTop
                                                                         multiplier:1
                                                                           constant:0]]];
        [NSLayoutConstraint activateConstraints:contraintsArr];
    }
}

@end

@implementation XIIndexLabelListCell
{
    UILabel *indexLabel;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier
{
    if(self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        
        indexLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        indexLabel.numberOfLines = 1;
        indexLabel.textColor = self.labelColor;
        indexLabel.font = self.labelFont;
        [self.contentView addSubview:indexLabel];
        indexLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [indexLabel setContentHuggingPriority:751 forAxis:0];
        [indexLabel setContentHuggingPriority:751 forAxis:1];
        
        NSArray *contraints = @[[NSLayoutConstraint constraintWithItem:indexLabel
                                                             attribute:NSLayoutAttributeLeft
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.contentView
                                                             attribute:NSLayoutAttributeLeft
                                                            multiplier:1
                                                              constant:0],
                                [NSLayoutConstraint constraintWithItem:indexLabel
                                                             attribute:NSLayoutAttributeTop
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.contentView
                                                             attribute:NSLayoutAttributeTop
                                                            multiplier:1
                                                              constant:0]];
        [NSLayoutConstraint activateConstraints:contraints];
        
        
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _contentLabel.numberOfLines = 0;
        _contentLabel.textColor = self.labelColor;
        _contentLabel.font = self.labelFont;
        [self.contentView addSubview:_contentLabel];
        _contentLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [_contentLabel setContentHuggingPriority:751 forAxis:0];
        [_contentLabel setContentHuggingPriority:751 forAxis:1];
    }
    return self;
}

- (void)setIndex:(NSInteger)index
{
    _index = index;
    
    indexLabel.font = [self labelFont];
    indexLabel.textColor = [self labelColor];
    
    NSString *plainText = [[NSNumber numberWithInteger:_index].stringValue stringByAppendingString:@"."];
    
    indexLabel.attributedText = [XILabelListCell makeRichText:plainText
                                                         font:indexLabel.font
                                                        color:indexLabel.textColor];
    
    [self setNeedsUpdateConstraints];
}

- (void)setText:(NSString *)text
{
    _text = text;
    
    NSAttributedString *atr = [XILabelListCell makeRichText:text font:self.labelFont color:self.labelColor];
    _contentLabel.attributedText = atr;
    
    [self setNeedsUpdateConstraints];
}

- (void)updateConstraints
{
    [super updateConstraints];
    
    if(_contentLabel.attributedText.string.length>0){
        

        CGSize indexSize = [XILabelListCell getSize:indexLabel.attributedText withConstraints:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
        
        CGFloat indexWidth = indexSize.width;
        
        CGSize cSize = self.constraintsSize;
        cSize.width = self.constraintsSize.width - indexWidth;
        
        _contentLabel.preferredMaxLayoutWidth = cSize.width;
        
        if(contraintsArr){
            [NSLayoutConstraint deactivateConstraints:contraintsArr];
            [contraintsArr removeAllObjects];
        }
        
        if(!contraintsArr){
            contraintsArr = [NSMutableArray array];
        }
        
        [contraintsArr addObjectsFromArray:@[[NSLayoutConstraint constraintWithItem:_contentLabel
                                                                          attribute:NSLayoutAttributeLeft
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:indexLabel
                                                                          attribute:NSLayoutAttributeRight
                                                                         multiplier:1
                                                                           constant:0],
                                             [NSLayoutConstraint constraintWithItem:_contentLabel
                                                                          attribute:NSLayoutAttributeTop
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:indexLabel
                                                                          attribute:NSLayoutAttributeTop
                                                                         multiplier:1
                                                                           constant:0]]];
        [NSLayoutConstraint activateConstraints:contraintsArr];
    }
}

@end

