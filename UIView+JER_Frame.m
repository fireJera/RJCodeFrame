//
//  UIImageView+UCN_Frame.m
//  UncleCon
//
//  Created by super on 03/11/2017.
//  Copyright © 2017 super. All rights reserved.
//

#import "UIView+JER_Frame.h"

@implementation UIView (JER_Frame)

- (void)setOrigin:(CGPoint)origin {
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (void)setSize:(CGSize)size {
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (void)setCenterX:(CGFloat)centerX {
    [self setLeft:centerX - self.width / 2];
}

- (void)setCenterY:(CGFloat)centerY {
    [self setTop:centerY - self.height / 2];
}

- (void)setWidth:(CGFloat)width {
    [self setSize:CGSizeMake(width, self.height)];
}

- (void)setHeight:(CGFloat)height {
    [self setSize:CGSizeMake(self.width, height)];
}

- (void)setTop:(CGFloat)top {
    [self setOrigin:CGPointMake(self.left, top)];
}

- (void)setBottom:(CGFloat)bottom {
    [self setOrigin:CGPointMake(self.left, bottom - self.height)];
}

- (void)setLeft:(CGFloat)left {
    [self setOrigin:CGPointMake(left, self.top)];
}

- (void)setRight:(CGFloat)right {
    [self setOrigin:CGPointMake(right - self.width, self.top)];
}

- (CGPoint)origin {
    return self.frame.origin;
}

- (CGSize)size {
    return self.frame.size;
}

- (CGFloat)centerX {
    return self.left + self.width / 2;
}

- (CGFloat)centerY {
    return self.top + self.height / 2;
}

- (CGFloat)width {
    return self.size.width;
}

- (CGFloat)height {
    return self.size.height;
}

- (CGFloat)top {
    return self.origin.y;
}

- (CGFloat)bottom {
    return self.top + self.height;
}

- (CGFloat)left {
    return self.origin.x;
}

- (CGFloat)right {
    return self.left + self.width;
}

@end
