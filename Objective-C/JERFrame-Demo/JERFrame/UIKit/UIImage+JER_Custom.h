//
//  UIImage+JER_Custom.h
//  Test
//
//  Created by super on 2018/11/17.
//  Copyright © 2018 Jeremy. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (JER_Custom)

+ (UIImage *)imageWithEmoji:(NSString *)emoji size:(CGFloat)size;

+ (UIImage *)imageWithColor:(UIColor *)color;

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

- (BOOL)hasAlphaChannel;

- (void)drawInRect:(CGRect)rect withContentModel:(UIViewContentMode)contentMode clipsToBounds:(BOOL)clips;

- (nullable UIImage *)imageByResizeToSize:(CGSize)size;

- (nullable UIImage *)imageByResizeToSize:(CGSize)size contentMode:(UIViewContentMode)contentMode;

- (nullable UIImage *)imageByCropToRect:(CGRect)rect;

- (nullable UIImage *)imageByRoundCornerRadius:(CGFloat)radius;

- (nullable UIImage *)imageByRoundCornerRadius:(CGFloat)radius
                                   borderWidth:(CGFloat)borderWidth
                                   borderColor:(nullable UIColor *)borderColor;

- (nullable UIImage *)imageByRoundCornerRadius:(CGFloat)radius
                                       corners:(UIRectCorner)corners
                                   borderWidth:(CGFloat)borderWidth
                                   borderColor:(UIColor *)borderColor
                                borderLineJoin:(CGLineJoin)borderLineJoin;

- (nullable UIImage *)imageByRotateLeft90;
- (nullable UIImage *)imageByRotateRight90;
- (nullable UIImage *)imageByRotate180;

- (nullable UIImage *)imageByFlipVertical;
- (nullable UIImage *)imageByFlipHorizontal;

- (nullable UIImage *)imageByBlurSoft;
- (nullable UIImage *)imageByBlurLight;
- (nullable UIImage *)imageByBlurExtraLight;
- (nullable UIImage *)imageByBlurDark;
- (nullable UIImage *)imageByBlurTint:(UIColor *)tintColor;

- (nullable UIImage *)imageByBlurRadius:(CGFloat)blurRadius
                              tintColor:(nullable UIColor *)tintColor
                               tintMode:(CGBlendMode)tintBlendMode
                             saturation:(CGFloat)saturation
                              maskImage:(nullable UIImage *)maskImage;


@end

NS_ASSUME_NONNULL_END
