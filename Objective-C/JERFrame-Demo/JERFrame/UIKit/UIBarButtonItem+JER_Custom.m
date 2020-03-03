//
//  UIBarButtonItem+JER_Custom.m
//  Test
//
//  Created by super on 2018/11/19.
//  Copyright © 2018 Jeremy. All rights reserved.
//

#import "UIBarButtonItem+JER_Custom.h"
#import <objc/runtime.h>

static int block_key;

@interface _JER_BarButtonItemTarget : NSObject

@property (nonatomic, copy) void(^block)(id sender);

- (instancetype)initWithBlock:(void(^)(id sender))block;

@end

@implementation _JER_BarButtonItemTarget

- (instancetype)initWithBlock:(void (^)(id))block {
    if (self = [super init]) {
        _block = [block copy];
    }
    return self;
}

- (void)invoke:(id)sender {
    if (_block) _block(sender);
}

@end

@implementation UIBarButtonItem (JER_Custom)

- (void)setActionBlock:(void (^)(id _Nonnull))actionBlock {
    _JER_BarButtonItemTarget * target = [[_JER_BarButtonItemTarget alloc] initWithBlock:actionBlock];
    objc_setAssociatedObject(self, &block_key, target, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self setTarget:target];
    [self setAction:@selector(invoke:)];
}

- (void(^)(id))actionBlock {
    _JER_BarButtonItemTarget * target = objc_getAssociatedObject(self, &block_key);
    return target.block;
}

@end
