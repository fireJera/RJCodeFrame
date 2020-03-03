//
//  TestObject.m
//  JERFrame
//
//  Created by super on 2018/11/22.
//  Copyright © 2018 Jeremy. All rights reserved.
//

#import "TestObject.h"

@interface TestObject () {
    NSUInteger _count;
}


@end

@implementation TestObject

- (id)init {
    self = [super init];
    return self;
}

- (BOOL)retainWeakReference {
    if (++_count > 3) return NO;
    return [super retainWeakReference];
}


@end
