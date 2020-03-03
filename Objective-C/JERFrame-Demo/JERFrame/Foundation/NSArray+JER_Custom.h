//
//  NSArray+JER_Custom.h
//  JERFrame
//
//  Created by super on 2018/11/21.
//  Copyright © 2018 Jeremy. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray<__covariant ObjectType> (JER_Custom)

- (nullable ObjectType)objectOrNilAtIndex:(NSUInteger)index;

@end


@interface NSMutableArray<ObjectType> (JER_Custom)

- (void)removeFirstObject;

- (nullable ObjectType)popFirstObject;

- (nullable ObjectType)popLastObject;

- (void)appendObject:(id)anObject;

- (void)appendObjects:(NSArray *)objects;

- (void)prependObject:(id)anObject;

- (void)prependObjects:(NSArray *)objects;

- (void)insertObjects:(NSArray *)objects atIndex:(NSUInteger)index;

- (void)reverse;

- (void)shuffle;

@end

NS_ASSUME_NONNULL_END
