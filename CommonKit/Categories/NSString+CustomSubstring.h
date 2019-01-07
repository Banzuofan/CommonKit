//
//  NSString+CustomSubstring.h
//  CommonKit
//
//  Created by YXLONG on 2019/1/7.
//  Copyright © 2019 yxlong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (CustomSubstring)
/**
 获取指定行数的文本
 
 @param aWidth 绘制区域的宽度
 @param numberOfLines 指定行数
 @param attributesFetcher 影响绘制区域大小的属性，比如字体、段落相关的属性
 @return <#return value description#>
 */
- (NSString *)substringWithDrawingRectWidth:(CGFloat)aWidth
                              numberOfLines:(NSUInteger)numberOfLines
                          attributesFetcher:(NSDictionary *(^)(void))attributesFetcher;

/**
 获取指定行数的文本
 
 @param aWidth 绘制区域的宽度
 @param numberOfLines 指定行数
 @param font 绘制文本的字体
 @return <#return value description#>
 */
- (NSString *)substringWithDrawingRectWidth:(CGFloat)aWidth
                              numberOfLines:(NSUInteger)numberOfLines
                                       font:(UIFont *)font;
@end

NS_ASSUME_NONNULL_END
