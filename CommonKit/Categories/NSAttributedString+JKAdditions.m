//
//  NSAttributedString+JKAdditions.m
//  JDCommonKit
//
//  Created by YXLONG on 2018/8/13.
//  Copyright © 2018年 yxlong. All rights reserved.
//

#import "NSAttributedString+JKAdditions.h"

@implementation NSAttributedString (JKAdditions)
+(NSAttributedString*)attributedStringWithString:(NSString*)string
{
    if (string)
    {
        return [[self alloc] initWithString:string];
    } else {
        return nil;
    }
}
+(NSAttributedString*)attributedStringWithAttributedString:(NSAttributedString*)attrStr
{
    if (attrStr)
    {
        return [[self alloc] initWithAttributedString:attrStr];
    } else {
        return nil;
    }
}

-(CGSize)sizeConstrainedToSize:(CGSize)maxSize
{
    return [self sizeConstrainedToSize:maxSize fitRange:NULL];
}

-(CGSize)sizeConstrainedToSize:(CGSize)maxSize fitRange:(NSRange*)fitRange
{
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)self);
    CGSize sz = CGSizeMake(0.f, 0.f);
    if (framesetter)
    {
        CFRange fitCFRange = CFRangeMake(0,0);
        sz = CTFramesetterSuggestFrameSizeWithConstraints(framesetter,CFRangeMake(0,0),NULL,maxSize,&fitCFRange);
        sz = CGSizeMake( floor(sz.width+1) , floor(sz.height+1) ); // take 1pt of margin for security
        CFRelease(framesetter);
        
        if (fitRange)
        {
            *fitRange = NSMakeRange((NSUInteger)fitCFRange.location, (NSUInteger)fitCFRange.length);
        }
    }
    return sz;
}
@end


////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////


@implementation NSMutableAttributedString (JDSTOCK_Mutable_CommonFunctions)

-(void)setFont:(UIFont*)font {
    [self setFontName:font.fontName size:font.pointSize];
}
-(void)setFont:(UIFont*)font range:(NSRange)range {
    [self setFontName:font.fontName size:font.pointSize range:range];
}
-(void)setFontName:(NSString*)fontName size:(CGFloat)size {
    [self setFontName:fontName size:size range:NSMakeRange(0,[self length])];
}
-(void)setFontName:(NSString*)fontName size:(CGFloat)size range:(NSRange)range {
    // kCTFontAttributeName
    CTFontRef aFont = CTFontCreateWithName((CFStringRef)fontName, size, NULL);
    if (!aFont) return;
    [self removeAttribute:(NSString*)kCTFontAttributeName range:range]; // Work around for Apple leak
    [self addAttribute:(NSString*)kCTFontAttributeName value:(__bridge id)aFont range:range];
    CFRelease(aFont);
}
-(void)setFontFamily:(NSString*)fontFamily size:(CGFloat)size bold:(BOOL)isBold italic:(BOOL)isItalic range:(NSRange)range {
    // kCTFontFamilyNameAttribute + kCTFontTraitsAttribute
    CTFontSymbolicTraits symTrait = (isBold?kCTFontBoldTrait:0) | (isItalic?kCTFontItalicTrait:0);
    NSDictionary* trait = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:symTrait] forKey:(NSString*)kCTFontSymbolicTrait];
    NSDictionary* attr = [NSDictionary dictionaryWithObjectsAndKeys:
                          fontFamily,kCTFontFamilyNameAttribute,
                          trait,kCTFontTraitsAttribute,nil];
    
    CTFontDescriptorRef desc = CTFontDescriptorCreateWithAttributes((CFDictionaryRef)attr);
    if (!desc) return;
    CTFontRef aFont = CTFontCreateWithFontDescriptor(desc, size, NULL);
    CFRelease(desc);
    if (!aFont) return;
    
    [self removeAttribute:(NSString*)kCTFontAttributeName range:range]; // Work around for Apple leak
    [self addAttribute:(NSString*)kCTFontAttributeName value:(__bridge id)aFont range:range];
    CFRelease(aFont);
}

-(void)setTextColor:(UIColor*)color {
    [self setTextColor:color range:NSMakeRange(0,[self length])];
}
-(void)setTextColor:(UIColor*)color range:(NSRange)range {
    // kCTForegroundColorAttributeName
    [self removeAttribute:(NSString*)kCTForegroundColorAttributeName range:range]; // Work around for Apple leak
    [self addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)color.CGColor range:range];
}

-(void)setTextIsUnderlined:(BOOL)underlined {
    [self setTextIsUnderlined:underlined range:NSMakeRange(0,[self length])];
}
-(void)setTextIsUnderlined:(BOOL)underlined range:(NSRange)range {
    int32_t style = underlined ? (kCTUnderlineStyleSingle|kCTUnderlinePatternSolid) : kCTUnderlineStyleNone;
    [self setTextUnderlineStyle:style range:range];
}
-(void)setTextUnderlineStyle:(int32_t)style range:(NSRange)range {
    [self removeAttribute:(NSString*)kCTUnderlineStyleAttributeName range:range]; // Work around for Apple leak
    [self addAttribute:(NSString*)kCTUnderlineStyleAttributeName value:[NSNumber numberWithInt:style] range:range];
}

-(void)changeFontWithTraits:(CTFontSymbolicTraits)traits
                       mask:(CTFontSymbolicTraits)traitsMask
                      range:(NSRange)range
              newFontFinder:( NSString*(^)(NSString* currentFontPostscriptName) )fontFinderBlock
{
    NSUInteger startPoint = range.location;
    NSRange effectiveRange;
    [self beginEditing];
    do {
        // Get font at startPoint
        CTFontRef currentFont = (__bridge CTFontRef)[self attribute:(__bridge NSString*)kCTFontAttributeName atIndex:startPoint effectiveRange:&effectiveRange];
        if (!currentFont)
        {
            currentFont = CTFontCreateUIFontForLanguage(kCTFontLabelFontType, 0.0, NULL);
        }
        // The range for which this font is effective
        NSRange fontRange = NSIntersectionRange(range, effectiveRange);
        // Create the font variant for this font according to new traits
        CTFontRef newFont = CTFontCreateCopyWithSymbolicTraits(currentFont, 0.0, NULL, traits, traitsMask);
        if (!newFont)
        {
            CFStringRef fontNameRef = CTFontCopyPostScriptName(currentFont);
            // Give a chance to try a hack for the private ".HelveticaNeueUI" font family, which is the default
            // font for labels in XIB, but fail to detect its italic variant correctly prior to iOS 6.1
            if (fontFinderBlock)
            {
                NSString* newFontName = fontFinderBlock((__bridge NSString*)fontNameRef);
                if (newFontName)
                {
                    CTFontDescriptorRef fontDesc = CTFontCopyFontDescriptor(currentFont);
                    NSDictionary* nameAttr = [NSDictionary dictionaryWithObject:newFontName forKey:@"NSFontNameAttribute"];
                    CTFontDescriptorRef newFontDesc = CTFontDescriptorCreateCopyWithAttributes(fontDesc, (__bridge CFDictionaryRef)nameAttr);
                    newFont = CTFontCreateWithFontDescriptor(newFontDesc, CTFontGetSize(currentFont), NULL);
                    CFRelease(fontDesc);
                    CFRelease(newFontDesc);
                }
            }
            // If still no luck, display a warning message in console
            if (!newFont)
            {
                NSLog(@"[OHAttributedLabel] Warning: can't find an italic font variant for font family %@. "
                      @"Try another font family (like Helvetica) instead.", (__bridge NSString*)fontNameRef);
            }
            if (fontNameRef) CFRelease(fontNameRef);
        }
        
        // Apply the new font with new traits
        if (newFont)
        {
            [self removeAttribute:(__bridge NSString*)kCTFontAttributeName range:fontRange]; // Work around for Apple leak
            [self addAttribute:(__bridge NSString*)kCTFontAttributeName value:(__bridge id)newFont range:fontRange];
            CFRelease(newFont);
        }
        
        // If the fontRange was not covering the whole range, continue with next run
        startPoint = NSMaxRange(effectiveRange);
    } while(startPoint<NSMaxRange(range));
    [self endEditing];
}

static NSString* const kHelveticaNeueUI             = @".HelveticaNeueUI";
static NSString* const kHelveticaNeueUI_Bold        = @".HelveticaNeueUI-Bold";
static NSString* const kHelveticaNeueUI_Italic      = @".HelveticaNeueUI-Italic";
static NSString* const kHelveticaNeueUI_Bold_Italic = @".HelveticaNeueUI-BoldItalic";

-(void)setTextBold:(BOOL)isBold range:(NSRange)range {
    [self changeFontWithTraits:(isBold?kCTFontTraitBold:0)
                          mask:kCTFontTraitBold
                         range:range newFontFinder:^NSString *(NSString *currentFontName)
     {
         if ([currentFontName isEqualToString:kHelveticaNeueUI_Italic] || [currentFontName isEqualToString:kHelveticaNeueUI_Bold_Italic])
         {
             // Italic private font
             return isBold ? kHelveticaNeueUI_Bold_Italic : kHelveticaNeueUI_Italic;
         } else if ([currentFontName isEqualToString:kHelveticaNeueUI] || [currentFontName isEqualToString:kHelveticaNeueUI_Bold]) {
             // Non-Italic private font
             return isBold ? kHelveticaNeueUI_Bold : kHelveticaNeueUI;
         } else {
             return nil;
         }
     }];
}

-(void)setTextAlignment:(CTTextAlignment)alignment lineBreakMode:(CTLineBreakMode)lineBreakMode {
    [self setTextAlignment:alignment lineBreakMode:lineBreakMode range:NSMakeRange(0,[self length])];
}
-(void)setTextAlignment:(CTTextAlignment)alignment lineBreakMode:(CTLineBreakMode)lineBreakMode range:(NSRange)range {
    // kCTParagraphStyleAttributeName > kCTParagraphStyleSpecifierAlignment
    CTParagraphStyleSetting paraStyles[2] = {
        {.spec = kCTParagraphStyleSpecifierAlignment, .valueSize = sizeof(CTTextAlignment), .value = (const void*)&alignment},
        {.spec = kCTParagraphStyleSpecifierLineBreakMode, .valueSize = sizeof(CTLineBreakMode), .value = (const void*)&lineBreakMode},
    };
    CTParagraphStyleRef aStyle = CTParagraphStyleCreate(paraStyles, 2);
    [self removeAttribute:(NSString*)kCTParagraphStyleAttributeName range:range]; // Work around for Apple leak
    [self addAttribute:(NSString*)kCTParagraphStyleAttributeName value:(id)aStyle range:range];
    CFRelease(aStyle);
}


-(void)setLink:(NSURL*)link range:(NSRange)range
{
    [self removeAttribute:NSLinkAttributeName range:range]; // Work around for Apple leak
    if (link)
    {
        [self addAttribute:NSLinkAttributeName value:(id)link range:range];
    }
}

@end


////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////


#define TTTFLOAT_MAX 100000

CGFLOAT_TYPE jr_CGFloat_ceil(CGFLOAT_TYPE cgfloat) {
#if CGFLOAT_IS_DOUBLE
    return ceil(cgfloat);
#else
    return ceilf(cgfloat);
#endif
}

CGSize jr_CTFramesetterSuggestFrameSizeForAttributedStringWithConstraints(CTFramesetterRef framesetter, NSAttributedString *attributedString, CGSize size, NSUInteger numberOfLines) {
    CFRange rangeToSize = CFRangeMake(0, (CFIndex)[attributedString length]);
    CGSize constraints = CGSizeMake(size.width, TTTFLOAT_MAX);
    
    if (numberOfLines == 1) {
        // If there is one line, the size that fits is the full width of the line
        constraints = CGSizeMake(TTTFLOAT_MAX, TTTFLOAT_MAX);
    } else if (numberOfLines > 0) {
        // If the line count of the label more than 1, limit the range to size to the number of lines that have been set
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, CGRectMake(0.0f, 0.0f, constraints.width, TTTFLOAT_MAX));
        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
        CFArrayRef lines = CTFrameGetLines(frame);
        
        if (CFArrayGetCount(lines) > 0) {
            NSInteger lastVisibleLineIndex = MIN((CFIndex)numberOfLines, CFArrayGetCount(lines)) - 1;
            CTLineRef lastVisibleLine = CFArrayGetValueAtIndex(lines, lastVisibleLineIndex);
            
            CFRange rangeToLayout = CTLineGetStringRange(lastVisibleLine);
            rangeToSize = CFRangeMake(0, rangeToLayout.location + rangeToLayout.length);
        }
        
        CFRelease(frame);
        CGPathRelease(path);
    }
    
    CGSize suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, rangeToSize, NULL, constraints, NULL);
    
    return CGSizeMake(jr_CGFloat_ceil(suggestedSize.width), jr_CGFloat_ceil(suggestedSize.height));
}

@implementation NSAttributedString (SizeFitsWithLimitedLines)

- (CGSize)sizeThatFitsWithConstraints:(CGSize)size
               limitedToNumberOfLines:(NSUInteger)numberOfLines
{
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)self);
    
    CGSize calculatedSize = jr_CTFramesetterSuggestFrameSizeForAttributedStringWithConstraints(framesetter, self, size, numberOfLines);
    
    CFRelease(framesetter);
    
    return calculatedSize;
}
@end
