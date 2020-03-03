//
//  UIControl+JER_Custom.h
//  Test
//
//  Created by super on 2018/11/19.
//  Copyright © 2018 Jeremy. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIControl (JER_Custom)

- (void)removeAllTargets;

- (void)setTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;

- (void)addBlockForControlEvents:(UIControlEvents)controlEvents block:(void(^)(id sender))block;

- (void)setBlockForControlEvents:(UIControlEvents)controlEvents block:(void(^)(id sender))block;

- (void)removeAllBlocksForControlEvents:(UIControlEvents)controlEvents;

@end

NS_ASSUME_NONNULL_END
