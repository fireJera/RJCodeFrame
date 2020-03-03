//
//  UIFont+JER_Custom.h
//  Test
//
//  Created by super on 2018/11/16.
//  Copyright © 2018 Jeremy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIFont (JER_Custom) <NSCoding>

@property (nonatomic, readonly) BOOL isBold NS_AVAILABLE_IOS(7_0);
@property (nonatomic, readonly) BOOL isItalic NS_AVAILABLE_IOS(7_0);
@property (nonatomic, readonly) BOOL isMonoSpace NS_AVAILABLE_IOS(7_0);
@property (nonatomic, readonly) BOOL isColorGlyphs NS_AVAILABLE_IOS(7_0);
@property (nonatomic, readonly) CGFloat fontWeight NS_AVAILABLE_IOS(7_0);

- (nullable UIFont *)fontWithBold NS_AVAILABLE_IOS(7_0);

- (nullable UIFont *)fontWithItalic NS_AVAILABLE_IOS(7_0);

- (nullable UIFont *)fontWithBoldItalic NS_AVAILABLE_IOS(7_0);

- (nullable UIFont *)fontWithNormal NS_AVAILABLE_IOS(7_0);

#pragma mark - creat font
+ (nullable UIFont *)fontWithCTFont:(CTFontRef)CTFont;

+ (nullable UIFont *)fontWithCGFont:(CGFontRef)CGFont size:(CGFloat)size;

- (nullable CTFontRef)CTFontRef CF_RETURNS_RETAINED;

- (nullable CGFontRef)CGFontRef CF_RETURNS_RETAINED;

+ (BOOL)loadFontFromPath:(NSString *)path;

+ (void)unloadFontFromPath:(NSString *)path;

+ (nullable UIFont *)loadFontFromData:(NSData *)data;

+ (BOOL)unloadFontFromData:(UIFont *)font;

+ (nullable NSData *)dataFromFont:(UIFont *)font;

+ (nullable NSData *)dataFromCGFont:(CGFontRef)cgFont;

@end

NS_ASSUME_NONNULL_END

@interface UIFont (JER_Common)

+ (UIFont *)PingFangMediumWithSize:(CGFloat)size;
+ (UIFont *)PingFangRegularWithSize:(CGFloat)size;
+ (UIFont *)PingFangSemboldWithSize:(CGFloat)size;

+ (UIFont *)PingFangMedium13;
+ (UIFont *)PingFangMedium15;
+ (UIFont *)PingFangMedium18;
+ (UIFont *)PingFangMedium24;
+ (UIFont *)PingFangMedium25;
+ (UIFont *)PingFangMedium35;

+ (UIFont *)PingFangRegular13;
+ (UIFont *)PingFangRegular15;
+ (UIFont *)PingFangRegular18;

@end
