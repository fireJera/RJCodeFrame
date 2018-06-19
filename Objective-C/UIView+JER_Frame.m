//
//  UIImageView+UCN_Frame.m
//  UncleCon
//
//  Created by super on 03/11/2017.
//  Copyright © 2017 super. All rights reserved.
//

#import "UIView+JER_Frame.h"

@implementation UIView (JER_Frame)

#pragma mark - setter
- (void)setLeft:(CGFloat)left {
    [self setOrigin:CGPointMake(left, self.top)];
}

- (void)setRight:(CGFloat)right {
    [self setOrigin:CGPointMake(right - self.width, self.top)];
}

- (void)setTop:(CGFloat)top {
    [self setOrigin:CGPointMake(self.left, top)];
}

- (void)setBottom:(CGFloat)bottom {
    [self setOrigin:CGPointMake(self.left, bottom - self.height)];
}

- (void)setOrigin:(CGPoint)origin {
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (void)setLeftBottom:(CGPoint)leftBottom {
    [self setOrigin:CGPointMake(leftBottom.x, leftBottom.y - self.height)];
}

- (void)setRightTop:(CGPoint)rightTop {
    [self setOrigin:CGPointMake(rightTop.x - self.width, rightTop.y)];
}

- (void)setRightBottom:(CGPoint)rightBottom {
    [self setOrigin:CGPointMake(rightBottom.x - self.width, rightBottom.y - self.height)];
}

- (void)setCenterX:(CGFloat)centerX {
    self.center = CGPointMake(centerX, self.centerY);
    //    [self setLeft:centerX - self.width / 2];
}

- (void)setCenterY:(CGFloat)centerY {
    self.center = CGPointMake(self.centerX, centerY);
    //    [self setTop:centerY - self.height / 2];
}

- (void)setWidth:(CGFloat)width {
    [self setSize:CGSizeMake(width, self.height)];
}

- (void)setHeight:(CGFloat)height {
    [self setSize:CGSizeMake(self.width, height)];
}

- (void)setSize:(CGSize)size {
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

#pragma mark - getter

- (CGFloat)left {
    return CGRectGetMinX(self.frame);
//    return self.origin.x;
}

- (CGFloat)right {
    return CGRectGetMaxX(self.frame);
//    return self.left + self.width;
}

- (CGFloat)top {
    return CGRectGetMinY(self.frame);
//    return self.origin.y;
}

- (CGFloat)bottom {
    return CGRectGetMaxY(self.frame);
//    return self.top + self.height;
}

- (CGPoint)origin {
    return self.frame.origin;
}

- (CGPoint)leftBottom {
    return CGPointMake(self.left, self.bottom);
}

- (CGPoint)rightTop {
    return CGPointMake(self.right, self.top);
}

- (CGPoint)rightBottom {
    return CGPointMake(self.right, self.bottom);
}

- (CGFloat)centerX {
    return CGRectGetMidX(self.frame);
//    return self.center.x;
}

- (CGFloat)centerY {
    return CGRectGetMidY(self.frame);
//    return self.center.y;
}

- (CGFloat)width {
    return CGRectGetWidth(self.bounds);
//    return self.size.width;
}

- (CGFloat)height {
    return CGRectGetHeight(self.bounds);
//    return self.size.height;
}

- (CGSize)size {
    return self.bounds.size;
}
@end
