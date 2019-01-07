//
//  NSString+CustomSubstring.m
//  CommonKit
//
//  Created by YXLONG on 2019/1/7.
//  Copyright © 2019 yxlong. All rights reserved.
//

#import "NSString+CustomSubstring.h"
#import <CoreText/CoreText.h>

@implementation NSString (CustomSubstring)
- (NSString *)substringWithDrawingRectWidth:(CGFloat)aWidth
                              numberOfLines:(NSUInteger)numberOfLines
                          attributesFetcher:(NSDictionary *(^)(void))attributesFetcher
{
    NSDictionary *attributes = nil;
    if(attributesFetcher){
        attributes = attributesFetcher();
    }
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:self attributes:attributes];
    
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attStr);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0, 0, aWidth, 100000));
    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, NULL);
    NSArray *lines = ( NSArray *)CTFrameGetLines(frame);
    NSMutableArray *linesArray = [[NSMutableArray alloc]init];
    for (id line in lines) {
        CTLineRef lineRef = (__bridge  CTLineRef )line;
        CFRange lineRange = CTLineGetStringRange(lineRef);
        NSRange range = NSMakeRange(lineRange.location, lineRange.length);
        NSString *lineString = [self substringWithRange:range];
        CFAttributedStringSetAttribute((CFMutableAttributedStringRef)attStr, lineRange, kCTKernAttributeName, (CFTypeRef)([NSNumber numberWithFloat:0.0]));
        CFAttributedStringSetAttribute((CFMutableAttributedStringRef)attStr, lineRange, kCTKernAttributeName, (CFTypeRef)([NSNumber numberWithInt:0.0]));
        [linesArray addObject:lineString];
    }
    
    CGPathRelease(path);
    CFRelease(frame);
    CFRelease(frameSetter);
    
    if(linesArray.count<=numberOfLines){
        return self;
    }
    
    NSMutableString *result = [NSMutableString string];
    for(int i=0;i<numberOfLines;i++){
        [result appendString:linesArray[i]];
    }
    return result;
}

- (NSString *)substringWithDrawingRectWidth:(CGFloat)aWidth
                              numberOfLines:(NSUInteger)numberOfLines
                                       font:(UIFont *)font
{
    if(!font){
        font = [UIFont systemFontOfSize:16];
    }
    return [self substringWithDrawingRectWidth:aWidth numberOfLines:numberOfLines attributesFetcher:^NSDictionary *{
        return @{NSFontAttributeName:font};
    }];
}
@end
