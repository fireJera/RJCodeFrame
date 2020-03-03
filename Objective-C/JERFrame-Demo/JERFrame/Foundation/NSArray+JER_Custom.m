//
//  NSArray+JER_Custom.m
//  JERFrame
//
//  Created by super on 2018/11/21.
//  Copyright © 2018 Jeremy. All rights reserved.
//

#import "NSArray+JER_Custom.h"

@implementation NSArray (JER_Custom)

- (id)objectOrNilAtIndex:(NSUInteger)index {
    return index < self.count ? self[index] : nil;
}

@end

@implementation NSMutableArray (JER_Custom)

- (void)removeFirstObject {
    if (self.count) {
        [self removeObjectAtIndex:0];
    }
}

- (id)popFirstObject {
    id pop = nil;
    if (self.count) {
        pop = self.firstObject;
        [self removeFirstObject];
    }
    return pop;
}

- (id)popLastObject {
    id pop = nil;
    if (self.count) {
        pop = self.lastObject;
        [self removeLastObject];
    }
    return pop;
}

- (void)appendObject:(id)anObject {
    [self addObject:anObject];
}

- (void)appendObjects:(NSArray *)objects {
    if (!objects) return;
    [self addObjectsFromArray:objects];
}

- (void)prependObject:(id)anObject {
    [self insertObject:anObject atIndex:0];
}

- (void)prependObjects:(NSArray *)objects {
    if (!objects) return;
    [self insertObjects:objects atIndex:0];
}

- (void)insertObjects:(NSArray *)objects atIndex:(NSUInteger)index {
    if (!objects) return;
    NSUInteger i = index;
    for (id obj in objects) {
        [self insertObject:obj atIndex:i++];
    }
//    [self insertObjects:objects atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, objects.count)]];
}

- (void)reverse {
    NSUInteger count = self.count;
    NSUInteger times = floor(count / 2);
    for (NSUInteger index = 0; index < times; index++) {
        [self exchangeObjectAtIndex:index withObjectAtIndex:count - (index + 1)];
    }
    
//    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        if (idx >= ceil(self.count / 2)) {
//            * stop = YES;
//        }
//        NSUInteger index = self.count - idx - 1;
//        [self exchangeObjectAtIndex:idx withObjectAtIndex:index];
//    }];
}

- (void)shuffle {
    for (NSUInteger i = self.count; i > 1; i--) {
        [self exchangeObjectAtIndex:i - 1 withObjectAtIndex:arc4random_uniform((uint32_t)i)];
    }
}

@end
