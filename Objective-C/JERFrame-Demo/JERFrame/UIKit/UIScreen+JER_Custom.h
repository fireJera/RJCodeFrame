//
//  UIScreen+JER_Custom.h
//  Test
//
//  Created by super on 2018/11/20.
//  Copyright © 2018 Jeremy. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIScreen (JER_Custom)

+ (CGFloat)screenScale;

- (CGRect)currentBounds;

- (CGRect)boundsForOrentation:(UIInterfaceOrientation)oriertation;

@property (nonatomic, readonly) CGSize sizeInPixel;

@property (nonatomic, readonly) CGFloat pixelsPerInch;

@end

NS_ASSUME_NONNULL_END
