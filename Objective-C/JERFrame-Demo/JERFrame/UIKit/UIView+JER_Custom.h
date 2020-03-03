//
//  UIView+JER_Custom.h
//  Test
//
//  Created by super on 2018/11/19.
//  Copyright © 2018 Jeremy. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (JER_Custom)

- (nullable UIImage *)snapshotImage;

- (nullable UIImage *)snapshotImageAfterScreenUpdates:(BOOL)afterUpdates;

- (nullable NSData *)snapshotPDF;

- (void)setLayerShadow:(nullable UIColor *)color offset:(CGSize)offset radius:(CGFloat)radius;

- (void)removeAllSubviews;


@property (nullable, nonatomic, readonly) UIViewController * viewController;

@property (nonatomic, readonly) CGFloat visibleAlpha;

- (CGPoint)convertPoin:(CGPoint)point toViewOrWindow:(nullable UIView *)view;

- (CGPoint)convertPoin:(CGPoint)point fromViewOrWindow:(UIView *)view;

- (CGRect)convertRect:(CGRect)rect toViewOrWindow:(nullable UIView *)view;

- (CGRect)convertRect:(CGRect)rect fromViewOrWindow:(nullable UIView *)view;

//frame

@property (nonatomic, assign) CGPoint origin;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) CGFloat centerX;
@property (nonatomic, assign) CGFloat centerY;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGFloat left;
@property (nonatomic, assign) CGFloat right;
@property (nonatomic, assign) CGFloat top;
@property (nonatomic, assign) CGFloat bottom;

@end

NS_ASSUME_NONNULL_END
