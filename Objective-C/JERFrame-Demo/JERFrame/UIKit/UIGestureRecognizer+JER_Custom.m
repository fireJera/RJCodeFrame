//
//  UIGestureRecognizer+JER_Custom.m
//  Test
//
//  Created by super on 2018/11/19.
//  Copyright © 2018 Jeremy. All rights reserved.
//

#import "UIGestureRecognizer+JER_Custom.h"
#import <objc/runtime.h>

static int block_key;

@interface _JER_GestureRecognizerTarget : NSObject

@property (nonatomic, copy) void(^block)(id sender);

- (instancetype)initWithBlock:(void(^)(id))block;

@end

@implementation _JER_GestureRecognizerTarget

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

@implementation UIGestureRecognizer (JER_Custom)

- (instancetype)initWithActionBlock:(void (^)(id _Nonnull))block {
    if (self = [super init]) {
        [self addActionBlock:block];
    }
    return self;
}

- (void)addActionBlock:(void (^)(id _Nonnull))block {
    _JER_GestureRecognizerTarget * target = [[_JER_GestureRecognizerTarget alloc] initWithBlock:block];
    NSMutableArray * targets = [self targets];
    [targets addObject:target];
    [self addTarget:target action:@selector(invoke:)];
}

- (void)removeAllActionBlocks {
    NSMutableArray * targets = [self targets];
    for (_JER_GestureRecognizerTarget * target in targets) {
        [self removeTarget:target action:@selector(invoke:)];
    }
    [targets removeAllObjects];
}

- (NSMutableArray *)targets {
    NSMutableArray * targets = objc_getAssociatedObject(self, &block_key);
    if (!targets) {
        targets = [NSMutableArray array];
        objc_setAssociatedObject(self, &block_key, targets, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return targets;
}

@end
