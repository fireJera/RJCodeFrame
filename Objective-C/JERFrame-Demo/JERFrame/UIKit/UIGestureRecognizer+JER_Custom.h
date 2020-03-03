//
//  UIGestureRecognizer+JER_Custom.h
//  Test
//
//  Created by super on 2018/11/19.
//  Copyright © 2018 Jeremy. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIGestureRecognizer (JER_Custom)

- (instancetype)initWithActionBlock:(void(^)(id sender))block;

- (void)addActionBlock:(void(^)(id sender))block;

- (void)removeAllActionBlocks;

@end

NS_ASSUME_NONNULL_END
