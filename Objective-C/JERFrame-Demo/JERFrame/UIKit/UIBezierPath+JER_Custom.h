//
//  UIBezierPath+JER_Custom.h
//  JERFrame
//
//  Created by super on 2018/11/20.
//  Copyright © 2018 Jeremy. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIBezierPath (JER_Custom)

+ (nullable UIBezierPath *)bezierPathWithText:(NSString *)text font:(UIFont *)font;

@end

NS_ASSUME_NONNULL_END
