//
//  UIFont+JER_Custom.m
//  Test
//
//  Created by super on 2018/11/16.
//  Copyright © 2018 Jeremy. All rights reserved.
//

#import "UIFont+JER_Custom.h"

@implementation UIFont (JER_Custom)

- (BOOL)isBold {
    if (![self respondsToSelector:@selector(fontDescriptor)]) return NO;
    return (self.fontDescriptor.symbolicTraits & UIFontDescriptorTraitBold) > 0;
}

- (BOOL)isItalic {
    if (![self respondsToSelector:@selector(fontDescriptor)]) return NO;
    return (self.fontDescriptor.symbolicTraits & UIFontDescriptorTraitItalic) > 0;
}

- (BOOL)isMonoSpace {
    if (![self respondsToSelector:@selector(fontDescriptor)]) return NO;
    return (self.fontDescriptor.symbolicTraits & UIFontDescriptorTraitMonoSpace) > 0;
}

- (BOOL)isColorGlyphs {
    if (![self respondsToSelector:@selector(fontDescriptor)]) return NO;
    return (CTFontGetSymbolicTraits((__bridge CTFontRef)self) & kCTFontColorGlyphsTrait) != 0;
}

- (CGFloat)fontWeight {
    NSDictionary * traits = [self.fontDescriptor objectForKey:UIFontDescriptorTraitsAttribute];
    return [traits[UIFontWeightTrait] floatValue];
}

- (UIFont *)fontWithBold {
    if (![self respondsToSelector:@selector(fontDescriptor)]) return self;
    return [UIFont fontWithDescriptor:[self.fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold] size:self.pointSize];
}

- (UIFont *)fontWithItalic {
    if (![self respondsToSelector:@selector(fontDescriptor)]) return self;
    return [UIFont fontWithDescriptor:[self.fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitItalic] size:self.pointSize];
}

- (UIFont *)fontWithBoldItalic {
    if (![self respondsToSelector:@selector(fontDescriptor)]) return self;
    return [UIFont fontWithDescriptor:[self.fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold | UIFontDescriptorTraitItalic] size:self.pointSize];
}

- (UIFont *)fontWithNormal {
    if (![self respondsToSelector:@selector(fontDescriptor)]) return self;
    return [UIFont fontWithDescriptor:[self.fontDescriptor fontDescriptorWithSymbolicTraits:0] size:self.pointSize];
}

+ (UIFont *)fontWithCTFont:(CTFontRef)CTFont {
    if (!CTFont) return nil;
    CFStringRef name = CTFontCopyPostScriptName(CTFont);
    if (!name) return nil;
    CGFloat size = CTFontGetSize(CTFont);
    UIFont * font = [UIFont fontWithName:(__bridge NSString *)name size:size];
    CFRelease(name);
    return font;
}

+ (UIFont *)fontWithCGFont:(CGFontRef)CGFont size:(CGFloat)size {
    if (!CGFont) return nil;
    CFStringRef name = CGFontCopyPostScriptName(CGFont);
    if (!name) return nil;
    UIFont * font = [UIFont fontWithName:(__bridge NSString *)name size:size];
    CFRelease(name);
    return font;
}

- (CTFontRef)CTFontRef {
    CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)self.fontName, self.pointSize, NULL);
    return font;
}

- (CGFontRef)CGFontRef {
    CGFontRef font = CGFontCreateWithFontName((__bridge CFStringRef)self.fontName);
    return font;
}

@end

@implementation UIFont (JER_Common)

static NSString * const MRDPINGFANGSCLIGHT = @"PingFangSC-Light";
static NSString * const MRDPINGFANGSCMEDIUM = @"PingFangSC-Medium";
static NSString * const MRDPINGFANGSCREGULAR = @"PingFangSC-Regular";
static NSString * const MRDPINGFANGSCSemibold = @"PingFangSC-Semibold";

+ (UIFont *)PingFangMediumWithSize:(CGFloat)size {
    return [UIFont fontWithName:MRDPINGFANGSCMEDIUM size:size];
}

+ (UIFont *)PingFangRegularWithSize:(CGFloat)size {
    return [UIFont fontWithName:MRDPINGFANGSCREGULAR size:size];
}

+ (UIFont *)PingFangSemboldWithSize:(CGFloat)size {
    return [UIFont fontWithName:MRDPINGFANGSCSemibold size:size];
}

+ (UIFont *)PingFangMedium13 {
    return [self PingFangMediumWithSize:13];
}

+ (UIFont *)PingFangMedium15 {
    return [self PingFangMediumWithSize:13];
}

+ (UIFont *)PingFangMedium18 {
    return [self PingFangMediumWithSize:13];
}

+ (UIFont *)PingFangMedium24 {
    return [self PingFangMediumWithSize:13];
}

+ (UIFont *)PingFangMedium25 {
    return [self PingFangMediumWithSize:13];
}

+ (UIFont *)PingFangMedium35 {
    return [self PingFangMediumWithSize:35];
}

+ (UIFont *)PingFangRegular13 {
    return [self PingFangRegularWithSize:13];
}

+ (UIFont *)PingFangRegular15 {
    return [self PingFangRegularWithSize:15];
}

+ (UIFont *)PingFangRegular18 {
    return [self PingFangRegularWithSize:18];
}

@end
