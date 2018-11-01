//
//  JRScrollJustifiedLabelView.m
//  JDStock
//
//  Created by YXLONG on 16/3/31.
//  Copyright © 2016年 jdjr. All rights reserved.
//

#import "XIJustifiedScrollLabelView.h"
#import "NSAttributedString+JKAdditions.h"

@implementation XIJustifiedScrollLabelView
{
    XIJustifiedLabelView *_labelView;
    UIScrollView *_scrollView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self=[super initWithFrame:frame]){
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        _scrollView.scrollsToTop = NO;
        [self addSubview:_scrollView];
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        
        _labelView = [[XIJustifiedLabelView alloc] initWithFrame:CGRectZero];
        _labelView.textColor = [UIColor blackColor];
        _labelView.font = [UIFont systemFontOfSize:16.0f];
        [_scrollView addSubview:_labelView];
    }
    return self;
}

- (void)setText:(NSString *)text
{
    _text = [text copy];
    [_labelView setText:text];
    [self adjustTextSize];
}

- (void)setTextColor:(UIColor *)textColor
{
    _textColor = textColor;
    _labelView.textColor = textColor;
}

- (void)setFont:(UIFont *)font
{
    _font = font;
    _labelView.font = font;
    [self adjustTextSize];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self adjustTextSize];
}

- (void)adjustTextSize
{
    if(_text && _text.length>0){
        CGSize constraintSize = CGSizeMake(self.frame.size.width, MAXFLOAT);
        NSAttributedString *aStr = [NSAttributedString attributedStringWithAttributedString:_labelView.attributedText];
        CGSize fitSize = [aStr sizeConstrainedToSize:constraintSize];
        CGRect r = CGRectMake(0, 0, _scrollView.bounds.size.width, fitSize.height);
        _labelView.frame = r;
        if(r.size.height>_scrollView.frame.size.height-5){
            fitSize.width = _scrollView.bounds.size.width;
            [_scrollView setContentSize:fitSize];
        }
    }
}

@end

//////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////

@interface XIJustifiedLabelView ()
- (void)formatString;
@end

@implementation XIJustifiedLabelView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setText:(NSString *)text
{
    _attributedText = [[NSMutableAttributedString alloc] initWithString:text];
    [self setNeedsDisplay];
}

- (NSMutableAttributedString *)attributedText
{
    [self formatString];
    return _attributedText;
}

- (void)setTextColor:(UIColor *)textColor
{
    _textColor = textColor;
    [self setNeedsDisplay];
}

- (void)setFont:(UIFont *)font
{
    _font = font;
    [self setNeedsDisplay];
}

- (void)formatString
{
    if(!_attributedText||_attributedText.length==0){
        return;
    }
    CTTextAlignment alignment = kCTJustifiedTextAlignment;
    
    CGFloat paragraphSpacing = 11.0;
    CGFloat paragraphSpacingBefore = 0.0;
    CGFloat firstLineHeadIndent = 0.0;
    CGFloat headIndent = 0.0;
    
    CTParagraphStyleSetting settings[] =
    {
        {kCTParagraphStyleSpecifierAlignment, sizeof(CTTextAlignment), &alignment},
        {kCTParagraphStyleSpecifierFirstLineHeadIndent, sizeof(CGFloat), &firstLineHeadIndent},
        {kCTParagraphStyleSpecifierHeadIndent, sizeof(CGFloat), &headIndent},
        {kCTParagraphStyleSpecifierParagraphSpacing, sizeof(CGFloat), &paragraphSpacing},
        {kCTParagraphStyleSpecifierParagraphSpacingBefore, sizeof(CGFloat), &paragraphSpacingBefore},
    };
    
    CTParagraphStyleRef style;
    style = CTParagraphStyleCreate(settings, sizeof(settings)/sizeof(CTParagraphStyleSetting));
    
    if (NULL == style) {
        // error...
        return;
    }
    
    [_attributedText addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:(__bridge NSObject*)style, (NSString*)kCTParagraphStyleAttributeName, nil]
                             range:NSMakeRange(0, [_attributedText length])];
    
    CFRelease(style);
    
    if (nil == _font) {
        _font = [UIFont boldSystemFontOfSize:12.0];
    }
    
    CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)_font.fontName, _font.pointSize, NULL);
    [_attributedText addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:(__bridge NSObject*)fontRef, (NSString*)kCTFontAttributeName, nil]
                             range:NSMakeRange(0, [_attributedText length])];
    CFRelease(fontRef);
    CGColorRef colorRef = _textColor.CGColor;
    [_attributedText addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:(__bridge NSObject*)colorRef,(NSString*)kCTForegroundColorAttributeName, nil]
                             range:NSMakeRange(0, [_attributedText length])];
    
}

- (void)drawRect:(CGRect)rect
{
    [self formatString];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(ctx, CGAffineTransformIdentity);
    
    CGContextTranslateCTM(ctx,0, self.bounds.size.height);
    CGContextScaleCTM(ctx, 1.0, -1.0);
    
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)_attributedText);
    
    CGRect bounds = self.bounds;
    bounds.origin.x = bounds.origin.x;
    bounds.size.width = bounds.size.width;
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, bounds);
    
    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, [_attributedText length]), path, NULL);
    CFRelease(path);
    
    CTFrameDraw(frame, ctx);
    CFRelease(frame);
    CFRelease(frameSetter);
}

@end
