//
//  UIImage+JER_Custom.m
//  Test
//
//  Created by super on 2018/11/17.
//  Copyright © 2018 Jeremy. All rights reserved.
//

#import "UIImage+JER_Custom.h"
#import <CoreText/CoreText.h>
#import "JERCGUtilities.h"
#import <Accelerate/Accelerate.h>

#ifndef YY_SWAP // swap two value
#define YY_SWAP(_a_, _b_)  do { __typeof__(_a_) _tmp_ = (_a_); (_a_) = (_b_); (_b_) = _tmp_; } while (0)
#endif

@implementation UIImage (JER_Custom)

+ (UIImage *)imageWithEmoji:(NSString *)emoji size:(CGFloat)size {
    if (emoji.length == 0) return nil;
    if (size < 1) return nil;
    
    CGFloat scale = [UIScreen mainScreen].scale;
    CTFontRef font = CTFontCreateWithName(CFSTR("AppleColorEmoji"), size * scale, NULL);
    if (!font) return nil;
    NSAttributedString * str = [[NSAttributedString alloc] initWithString:emoji attributes:@{(__bridge id)kCTFontNameAttribute:(__bridge id)font, (__bridge id)kCTForegroundColorAttributeName:(__bridge id)[UIColor whiteColor].CGColor}];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(NULL, scale * size, scale * scale, 8, 0, colorSpace, kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedFirst);
    CGContextSetInterpolationQuality(ctx, kCGInterpolationHigh);
    CTLineRef line = CTLineCreateWithAttributedString((__bridge CFTypeRef)str);
    CGRect bounds = CTLineGetBoundsWithOptions(line, kCTLineBoundsUseGlyphPathBounds);
    CGContextSetTextPosition(ctx, 0, -bounds.origin.y);
    CTLineDraw(line, ctx);
    CGImageRef imageRef = CGBitmapContextCreateImage(ctx);
    UIImage * image = [UIImage imageWithCGImage:imageRef scale:scale orientation:UIImageOrientationUp];
    CFRelease(font);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(ctx);
    if (line) CFRelease(line);
    if (imageRef) CFRelease(imageRef);
    
    return image;
}

+ (UIImage *)imageWithColor:(UIColor *)color {
    return [self imageWithColor:color size:CGSizeMake(1, 1)];
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
    if (!color || size.width <= 0 || size.height <= 0) return nil;
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (BOOL)hasAlphaChannel {
    if (self.CGImage == NULL) return NO;
    CGImageAlphaInfo alpha = CGImageGetAlphaInfo(self.CGImage) & kCGBitmapAlphaInfoMask;
    return (alpha == kCGImageAlphaFirst ||
            alpha == kCGImageAlphaLast ||
            alpha == kCGImageAlphaPremultipliedFirst ||
            alpha == kCGImageAlphaPremultipliedLast);
}

- (void)drawInRect:(CGRect)rect withContentModel:(UIViewContentMode)contentMode clipsToBounds:(BOOL)clips {
    CGRect drawRect = JERCGRectFitWithContentMode(rect, self.size, contentMode);
    if (drawRect.size.width == 0 || drawRect.size.height == 0) return;
    if (clips) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        if (context) {
            CGContextSaveGState(context);
            CGContextAddRect(context, rect);
            CGContextClip(context);
            [self drawInRect:drawRect];
            CGContextRestoreGState(context);
        }
    } else {
        [self drawInRect:drawRect];
    }
}

- (UIImage *)imageByResizeToSize:(CGSize)size {
    if (size.width <= 0 || size.height <= 0) return nil;
    UIGraphicsBeginImageContextWithOptions(size, NO, self.scale);
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)imageByResizeToSize:(CGSize)size contentMode:(UIViewContentMode)contentMode {
    if (size.width <= 0 || size.height <= 0) return nil;
    UIGraphicsBeginImageContextWithOptions(size, NO, self.scale);
    [self drawInRect:CGRectMake(0, 0, size.width, size.height) withContentModel:contentMode clipsToBounds:NO];
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)imageByCropToRect:(CGRect)rect {
    if (rect.size.width <= 0 || rect.size.height <= 0) return nil;
    rect.origin.x *= self.scale;
    rect.origin.y *= self.scale;
    rect.size.width *= self.scale;
    rect.size.height *= self.scale;
    
    CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, rect);
    UIImage * image = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
    CFRelease(imageRef);
    return image;
}

- (UIImage *)imageByRoundCornerRadius:(CGFloat)radius {
    return [self imageByRoundCornerRadius:radius borderWidth:0 borderColor:nil];
}

- (UIImage *)imageByRoundCornerRadius:(CGFloat)radius borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor {
    return [self imageByRoundCornerRadius:radius corners:UIRectCornerAllCorners borderWidth:borderWidth borderColor:borderColor borderLineJoin:kCGLineJoinMiter];
}

//- (UIImage *)imageByRoundCornerRadius:(CGFloat)radius
//                              corners:(UIRectCorner)corners
//                          borderWidth:(CGFloat)borderWidth
//                          borderColor:(UIColor *)borderColor
//                       borderLineJoin:(CGLineJoin)borderLineJoin {
//    if (corners != UIRectCornerAllCorners) {
//        UIRectCorner tmp = 0;
//        
//    }
//}

- (UIImage *)imageByRotate:(CGFloat)radians fitSize:(BOOL)fitSize {
    size_t width = (size_t)CGImageGetWidth(self.CGImage);
    size_t height = (size_t)CGImageGetHeight(self.CGImage);
    CGRect newRect = CGRectApplyAffineTransform(CGRectMake(0., 0., width, height),
                                                fitSize ? CGAffineTransformMakeRotation(radians) : CGAffineTransformIdentity);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 (size_t)newRect.size.width,
                                                 (size_t)newRect.size.height,
                                                 8,
                                                 (size_t)newRect.size.width * 4,
                                                 colorSpace,
                                                 kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(colorSpace);
    if (!context) return nil;
    
    CGContextSetShouldAntialias(context, true);
    CGContextSetAllowsAntialiasing(context, true);
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    
    CGContextTranslateCTM(context, +(newRect.size.width * 0.5), +(newRect.size.height * 0.5));
    CGContextRotateCTM(context, radians);
    
    CGContextDrawImage(context, CGRectMake(-(width * 0.5), -(height * 0.5), width, height), self.CGImage);
    CGImageRef imgRef = CGBitmapContextCreateImage(context);
    UIImage *img = [UIImage imageWithCGImage:imgRef scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(imgRef);
    CGContextRelease(context);
    return img;
}

- (UIImage *)_yy_flipHorizontal:(BOOL)horizontal vertical:(BOOL)vertical {
    if (!self.CGImage) return nil;
    size_t width = (size_t)CGImageGetWidth(self.CGImage);
    size_t height = (size_t)CGImageGetHeight(self.CGImage);
    size_t bytesPerRow = width * 4;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(colorSpace);
    if (!context) return nil;
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), self.CGImage);
    UInt8 *data = (UInt8 *)CGBitmapContextGetData(context);
    if (!data) {
        CGContextRelease(context);
        return nil;
    }
    vImage_Buffer src = { data, height, width, bytesPerRow };
    vImage_Buffer dest = { data, height, width, bytesPerRow };
    if (vertical) {
        vImageVerticalReflect_ARGB8888(&src, &dest, kvImageBackgroundColorFill);
    }
    if (horizontal) {
        vImageHorizontalReflect_ARGB8888(&src, &dest, kvImageBackgroundColorFill);
    }
    CGImageRef imgRef = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    UIImage *img = [UIImage imageWithCGImage:imgRef scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(imgRef);
    return img;
}

- (UIImage *)imageByRotateLeft90 {
    return [self imageByRotate:90 fitSize:YES];
}

- (UIImage *)imageByRotateRight90 {
    return [self imageByRotate:90 fitSize:YES];
}

- (UIImage *)imageByRotate180 {
    return [self _yy_flipHorizontal:YES vertical:YES];
}

- (UIImage *)imageByFlipVertical {
    return [self _yy_flipHorizontal:NO vertical:YES];
}

- (UIImage *)imageByFlipHorizontal {
    return [self _yy_flipHorizontal:YES vertical:NO];
}

- (UIImage *)imageByBlurSoft {
    return [self imageByBlurRadius:60 tintColor:[UIColor colorWithWhite:0.84 alpha:0.36] tintMode:kCGBlendModeNormal saturation:1.8 maskImage:nil];
}

- (UIImage *)imageByBlurLight {
    return [self imageByBlurRadius:60 tintColor:[UIColor colorWithWhite:1.0 alpha:0.3] tintMode:kCGBlendModeNormal saturation:1.8 maskImage:nil];
}

- (UIImage *)imageByBlurExtraLight {
    return [self imageByBlurRadius:40 tintColor:[UIColor colorWithWhite:0.97 alpha:0.82] tintMode:kCGBlendModeNormal saturation:1.8 maskImage:nil];
}

- (UIImage *)imageByBlurDark {
    return [self imageByBlurRadius:40 tintColor:[UIColor colorWithWhite:0.11 alpha:0.73] tintMode:kCGBlendModeNormal saturation:1.8 maskImage:nil];
}

- (UIImage *)imageByBlurTint:(UIColor *)tintColor {
    const CGFloat EffextColorAlpha = 0.6;
    UIColor * effectColor = tintColor;
    size_t componentCount = CGColorGetNumberOfComponents(tintColor.CGColor);
    if (componentCount == 2) {
        CGFloat b;
        if ([tintColor getWhite:&b alpha:NULL]) {
            effectColor = [UIColor colorWithWhite:b alpha:EffextColorAlpha];
        }
    } else {
        CGFloat r, g, b;
        if ([tintColor getRed:&r green:&g blue:&b alpha:NULL]) {
            effectColor = [UIColor colorWithRed:r green:g blue:b alpha:EffextColorAlpha];
        }
    }
    return [self imageByBlurRadius:20 tintColor:effectColor tintMode:kCGBlendModeNormal saturation:-1.0 maskImage:nil];
}

- (UIImage *)imageByBlurRadius:(CGFloat)blurRadius
                     tintColor:(UIColor *)tintColor
                      tintMode:(CGBlendMode)tintBlendMode
                    saturation:(CGFloat)saturation
                     maskImage:(UIImage *)maskImage {
    if (self.size.width < 1 || self.size.height < 1) {
        NSLog(@"UIImage+YYAdd error: invalid size: (%.2f x %.2f). Both dimensions must be >= 1: %@", self.size.width, self.size.height, self);
        return nil;
    }
    if (!self.CGImage) {
        NSLog(@"UIImage+YYAdd error: inputImage must be backed by a CGImage: %@", self);
        return nil;
    }
    if (maskImage && !maskImage.CGImage) {
        NSLog(@"UIImage+YYAdd error: effectMaskImage must be backed by a CGImage: %@", maskImage);
        return nil;
    }
    
    // iOS7 and above can use new func.
    BOOL hasNewFunc = (long)vImageBuffer_InitWithCGImage != 0 && (long)vImageCreateCGImageFromBuffer != 0;
    BOOL hasBlur = blurRadius > __FLT_EPSILON__;
    BOOL hasSaturation = fabs(saturation - 1.0) > __FLT_EPSILON__;
    
    CGSize size = self.size;
    CGRect rect = { CGPointZero, size };
    CGFloat scale = self.scale;
    CGImageRef imageRef = self.CGImage;
    BOOL opaque = NO;
    
    if (!hasBlur && !hasSaturation) {
        return [self _yy_mergeImageRef:imageRef tintColor:tintColor tintBlendMode:tintBlendMode maskImage:maskImage opaque:opaque];
    }
    
    vImage_Buffer effect = { 0 }, scratch = { 0 };
    vImage_Buffer *input = NULL, *output = NULL;
    
    vImage_CGImageFormat format = {
        .bitsPerComponent = 8,
        .bitsPerPixel = 32,
        .colorSpace = NULL,
        .bitmapInfo = kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little, //requests a BGRA buffer.
        .version = 0,
        .decode = NULL,
        .renderingIntent = kCGRenderingIntentDefault
    };
    
    if (hasNewFunc) {
        vImage_Error err;
        err = vImageBuffer_InitWithCGImage(&effect, &format, NULL, imageRef, kvImagePrintDiagnosticsToConsole);
        if (err != kvImageNoError) {
            NSLog(@"UIImage+YYAdd error: vImageBuffer_InitWithCGImage returned error code %zi for inputImage: %@", err, self);
            return nil;
        }
        err = vImageBuffer_Init(&scratch, effect.height, effect.width, format.bitsPerPixel, kvImageNoFlags);
        if (err != kvImageNoError) {
            NSLog(@"UIImage+YYAdd error: vImageBuffer_Init returned error code %zi for inputImage: %@", err, self);
            return nil;
        }
    } else {
        UIGraphicsBeginImageContextWithOptions(size, opaque, scale);
        CGContextRef effectCtx = UIGraphicsGetCurrentContext();
        CGContextScaleCTM(effectCtx, 1.0, -1.0);
        CGContextTranslateCTM(effectCtx, 0, -size.height);
        CGContextDrawImage(effectCtx, rect, imageRef);
        effect.data     = CGBitmapContextGetData(effectCtx);
        effect.width    = CGBitmapContextGetWidth(effectCtx);
        effect.height   = CGBitmapContextGetHeight(effectCtx);
        effect.rowBytes = CGBitmapContextGetBytesPerRow(effectCtx);
        
        UIGraphicsBeginImageContextWithOptions(size, opaque, scale);
        CGContextRef scratchCtx = UIGraphicsGetCurrentContext();
        scratch.data     = CGBitmapContextGetData(scratchCtx);
        scratch.width    = CGBitmapContextGetWidth(scratchCtx);
        scratch.height   = CGBitmapContextGetHeight(scratchCtx);
        scratch.rowBytes = CGBitmapContextGetBytesPerRow(scratchCtx);
    }
    
    input = &effect;
    output = &scratch;
    
    if (hasBlur) {
        // A description of how to compute the box kernel width from the Gaussian
        // radius (aka standard deviation) appears in the SVG spec:
        // http://www.w3.org/TR/SVG/filters.html#feGaussianBlurElement
        //
        // For larger values of 's' (s >= 2.0), an approximation can be used: Three
        // successive box-blurs build a piece-wise quadratic convolution kernel, which
        // approximates the Gaussian kernel to within roughly 3%.
        //
        // let d = floor(s * 3*sqrt(2*pi)/4 + 0.5)
        //
        // ... if d is odd, use three box-blurs of size 'd', centered on the output pixel.
        //
        CGFloat inputRadius = blurRadius * scale;
        if (inputRadius - 2.0 < __FLT_EPSILON__) inputRadius = 2.0;
        uint32_t radius = floor((inputRadius * 3.0 * sqrt(2 * M_PI) / 4 + 0.5) / 2);
        radius |= 1; // force radius to be odd so that the three box-blur methodology works.
        int iterations;
        if (blurRadius * scale < 0.5) iterations = 1;
        else if (blurRadius * scale < 1.5) iterations = 2;
        else iterations = 3;
        NSInteger tempSize = vImageBoxConvolve_ARGB8888(input, output, NULL, 0, 0, radius, radius, NULL, kvImageGetTempBufferSize | kvImageEdgeExtend);
        void *temp = malloc(tempSize);
        for (int i = 0; i < iterations; i++) {
            vImageBoxConvolve_ARGB8888(input, output, temp, 0, 0, radius, radius, NULL, kvImageEdgeExtend);
            YY_SWAP(input, output);
        }
        free(temp);
    }
    
    
    if (hasSaturation) {
        // These values appear in the W3C Filter Effects spec:
        // https://dvcs.w3.org/hg/FXTF/raw-file/default/filters/Publish.html#grayscaleEquivalent
        CGFloat s = saturation;
        CGFloat matrixFloat[] = {
            0.0722 + 0.9278 * s,  0.0722 - 0.0722 * s,  0.0722 - 0.0722 * s,  0,
            0.7152 - 0.7152 * s,  0.7152 + 0.2848 * s,  0.7152 - 0.7152 * s,  0,
            0.2126 - 0.2126 * s,  0.2126 - 0.2126 * s,  0.2126 + 0.7873 * s,  0,
            0,                    0,                    0,                    1,
        };
        const int32_t divisor = 256;
        NSUInteger matrixSize = sizeof(matrixFloat) / sizeof(matrixFloat[0]);
        int16_t matrix[matrixSize];
        for (NSUInteger i = 0; i < matrixSize; ++i) {
            matrix[i] = (int16_t)roundf(matrixFloat[i] * divisor);
        }
        vImageMatrixMultiply_ARGB8888(input, output, matrix, divisor, NULL, NULL, kvImageNoFlags);
        YY_SWAP(input, output);
    }
    
    UIImage *outputImage = nil;
    if (hasNewFunc) {
        CGImageRef effectCGImage = NULL;
        effectCGImage = vImageCreateCGImageFromBuffer(input, &format, &_yy_cleanupBuffer, NULL, kvImageNoAllocate, NULL);
        if (effectCGImage == NULL) {
            effectCGImage = vImageCreateCGImageFromBuffer(input, &format, NULL, NULL, kvImageNoFlags, NULL);
            free(input->data);
        }
        free(output->data);
        outputImage = [self _yy_mergeImageRef:effectCGImage tintColor:tintColor tintBlendMode:tintBlendMode maskImage:maskImage opaque:opaque];
        CGImageRelease(effectCGImage);
    } else {
        CGImageRef effectCGImage;
        UIImage *effectImage;
        if (input != &effect) effectImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        if (input == &effect) effectImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        effectCGImage = effectImage.CGImage;
        outputImage = [self _yy_mergeImageRef:effectCGImage tintColor:tintColor tintBlendMode:tintBlendMode maskImage:maskImage opaque:opaque];
    }
    return outputImage;
}

// Helper function to handle deferred cleanup of a buffer.
static void _yy_cleanupBuffer(void *userData, void *buf_data) {
    free(buf_data);
}

// Helper function to add tint and mask.
- (UIImage *)_yy_mergeImageRef:(CGImageRef)effectCGImage
                     tintColor:(UIColor *)tintColor
                 tintBlendMode:(CGBlendMode)tintBlendMode
                     maskImage:(UIImage *)maskImage
                        opaque:(BOOL)opaque {
    BOOL hasTint = tintColor != nil && CGColorGetAlpha(tintColor.CGColor) > __FLT_EPSILON__;
    BOOL hasMask = maskImage != nil;
    CGSize size = self.size;
    CGRect rect = { CGPointZero, size };
    CGFloat scale = self.scale;
    
    if (!hasTint && !hasMask) {
        return [UIImage imageWithCGImage:effectCGImage];
    }
    
    UIGraphicsBeginImageContextWithOptions(size, opaque, scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextTranslateCTM(context, 0, -size.height);
    if (hasMask) {
        CGContextDrawImage(context, rect, self.CGImage);
        CGContextSaveGState(context);
        CGContextClipToMask(context, rect, maskImage.CGImage);
    }
    CGContextDrawImage(context, rect, effectCGImage);
    if (hasTint) {
        CGContextSaveGState(context);
        CGContextSetBlendMode(context, tintBlendMode);
        CGContextSetFillColorWithColor(context, tintColor.CGColor);
        CGContextFillRect(context, rect);
        CGContextRestoreGState(context);
    }
    if (hasMask) {
        CGContextRestoreGState(context);
    }
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return outputImage;
}

@end
