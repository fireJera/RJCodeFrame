//
//  UIBezierPath+JER_Custom.m
//  JERFrame
//
//  Created by super on 2018/11/20.
//  Copyright © 2018 Jeremy. All rights reserved.
//

#import "UIBezierPath+JER_Custom.h"
#import <CoreText/CoreText.h>
#import "UIFont+JER_Custom.h"

@implementation UIBezierPath (JER_Custom)

//+ (UIBezierPath *)bezierPathWithText:(NSString *)text font:(UIFont *)font {
//    CTFontRef ctFont = font.CTFontRef;
//    if (!ctFont) return nil;
//    NSDictionary * attrs = @{ (__bridge id)kCTFontAttributeName : (__bridge id)ctFont};
//    NSAttributedString * attrString = [[NSAttributedString alloc] initWithString:text attributes:attrs];
//    CFRelease(ctFont);
//    CTLineRef line = CTLineCreateWithAttributedString((__bridge CFTypeRef)attrString);
//    
//    if (!line) return nil;
//    
//    CGMutablePathRef cgPath = CGPathCreateMutable();
//    CFArrayRef runs = CTLineGetGlyphRuns(line);
//}

@end
