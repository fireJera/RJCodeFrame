//
//  UIControl+JER_Custom.m
//  Test
//
//  Created by super on 2018/11/19.
//  Copyright © 2018 Jeremy. All rights reserved.
//

#import "UIControl+JER_Custom.h"
#import <objc/runtime.h>

static int block_key;

@interface _JER_BlockTargets : NSObject

@property (nonatomic, copy) void(^block)(id sender);
@property (nonatomic, assign) UIControlEvents events;

- (instancetype)initWithBlock:(void(^)(id sender))block
                       events:(UIControlEvents)events;

- (void)invoke:(id)sender;

@end

@implementation _JER_BlockTargets

- (instancetype)initWithBlock:(void (^)(id))block events:(UIControlEvents)events {
    if (self = [super init]) {
        _block = [block copy];
        _events = events;
    }
    return self;
}

- (void)invoke:(id)sender {
    if (_block) _block(sender);
}

@end

@implementation UIControl (JER_Custom)

- (void)removeAllTargets {
    [[self allTargets] enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
        [self removeTarget:obj action:NULL forControlEvents:UIControlEventAllEvents];
    }];
    [[self _jer_allTargets] removeAllObjects];
}

- (void)setTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents {
    if (!target || !action || !controlEvents) return;
    NSSet * targets = self.allTargets;
    for (id currentTarget in targets) {
        NSArray * actions = [self actionsForTarget:currentTarget forControlEvent:controlEvents];
        for (NSString * currentAction in actions) {
            [self removeTarget:target action:NSSelectorFromString(currentAction) forControlEvents:controlEvents];
        }
    }
    [self addTarget:target action:action forControlEvents:UIControlEventAllEvents];
}

- (void)setBlockForControlEvents:(UIControlEvents)controlEvents block:(void (^)(id _Nonnull))block {
    [self removeAllBlocksForControlEvents:controlEvents];
    [self addBlockForControlEvents:controlEvents block:block];
}

- (void)addBlockForControlEvents:(UIControlEvents)controlEvents block:(void (^)(id _Nonnull))block {
    if (!controlEvents) return;
    NSMutableArray * targets = [self _jer_allTargets];
    _JER_BlockTargets * target = [[_JER_BlockTargets alloc] initWithBlock:block events:controlEvents];
    [self addTarget:target action:@selector(invoke:) forControlEvents:controlEvents];
    [targets addObject:target];
}

- (void)removeAllBlocksForControlEvents:(UIControlEvents)controlEvents {
    if (!controlEvents) return;
    NSMutableArray * targets = [self _jer_allTargets];
    NSMutableArray * removes = [NSMutableArray array];
    for (_JER_BlockTargets * target in targets) {
        if (target.events & controlEvents) {
            UIControlEvents newEvent = target.events & (~controlEvents);
            if (newEvent) {
                [self removeTarget:target action:@selector(invoke:) forControlEvents:target.events];
                target.events = newEvent;
                [self addTarget:target action:@selector(invoke:) forControlEvents:target.events];
            } else {
                [self removeTarget:target action:@selector(invoke:) forControlEvents:controlEvents];
                [removes addObject:target];
            }
        }
    }
    [targets removeObjectsInArray:removes];
}

- (NSMutableArray *)_jer_allTargets {
    NSMutableArray * targets = objc_getAssociatedObject(self, &block_key);
    if (!targets) {
        targets = [NSMutableArray array];
        objc_setAssociatedObject(self, &block_key, targets, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return targets;
}

@end
