//
//  NSThread+JER_Custom.m
//  JERFrame
//
//  Created by super on 2018/11/22.
//  Copyright © 2018 Jeremy. All rights reserved.
//

#import "NSThread+JER_Custom.h"
#import <CoreFoundation/CoreFoundation.h>

#if __has_feature(objc_arc)
#error This file must be compiled without ARC. Specify the -fno-objc-arc flag to this file
#endif

static NSString * JERThreadAutoreleasePoolKey = @"kJERThreadAutoreleasePoolKey";
static NSString * JERThreadAutoreleasePoolStackKey = @"kJERThreadAutoreleasePoolStackKey";

static const void * PoolStackRetainCallBack(CFAllocatorRef allocator, const void *value) {
    return value;
}

static void PoolStatckReleaseCallBack(CFAllocatorRef allocator, const void *value) {
    CFRelease(value);
}

static inline void JERAutoreleasePoolPush() {
    NSMutableDictionary * dic = [NSThread currentThread].threadDictionary;
    NSMutableArray * poolStack = dic[JERThreadAutoreleasePoolStackKey];
    
    if (!poolStack) {
        CFArrayCallBacks callbacks = {0};
        callbacks.retain = PoolStackRetainCallBack;
        callbacks.release = PoolStatckReleaseCallBack;
        poolStack = (id)CFArrayCreateMutable(CFAllocatorGetDefault(), 0, &callbacks);
        dic[JERThreadAutoreleasePoolStackKey] = poolStack;
        CFRelease(poolStack);
    }
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    [poolStack addObject:pool];
}

static inline void JERAutoreleasePoolPop() {
    NSDictionary * dic = [NSThread currentThread].threadDictionary;
    NSMutableArray * poolStack = dic[JERThreadAutoreleasePoolStackKey];
    [poolStack removeLastObject];
}

static void JERRunloopAutoreleasePoolObserverCallback(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
    switch (activity) {
        case kCFRunLoopEntry:
            JERAutoreleasePoolPush();
            break;
        case kCFRunLoopBeforeWaiting: {
            JERAutoreleasePoolPop();
            JERAutoreleasePoolPush();
        }
//        case kCFRunLoopBeforeTimers:
//        case kCFRunLoopBeforeSources:
//        case kCFRunLoopAfterWaiting:
            break;
        case kCFRunLoopExit:
            JERAutoreleasePoolPop();
            break;
        default:
            break;
    }
}

static void JERRunloopAutoreleasePoolSetUp() {
    CFRunLoopRef runloop = CFRunLoopGetCurrent();
    CFRunLoopObserverRef pushObserver;
    pushObserver = CFRunLoopObserverCreate(CFAllocatorGetDefault(),
                                                            kCFRunLoopEntry,
                                                            true,
                                                            -0x7FFFFFFF, //before other observer
                                                            JERRunloopAutoreleasePoolObserverCallback,
                                                            NULL);
    
    CFRunLoopAddObserver(runloop, pushObserver, kCFRunLoopCommonModes);
    CFRelease(pushObserver);
    
    CFRunLoopObserverRef popObserver;
    popObserver = CFRunLoopObserverCreate(CFAllocatorGetDefault(),
                                          kCFRunLoopBeforeWaiting | kCFRunLoopExit,
                                          true,
                                          0x7FFFFFFF, // after other observer
                                          JERRunloopAutoreleasePoolObserverCallback,
                                          NULL);
    
    
    CFRunLoopAddObserver(runloop, popObserver, kCFRunLoopCommonModes);
    CFRelease(popObserver);
}

@implementation NSThread (JER_Custom)

+ (void)addAutoreleasePoolToCurrentRunloop {
    if ([NSThread isMainThread]) return;
    NSThread * currentThread = [NSThread currentThread];
    if (!currentThread) return;
    if (currentThread.threadDictionary[JERThreadAutoreleasePoolKey]) return;
    JERRunloopAutoreleasePoolSetUp();
    currentThread.threadDictionary[JERThreadAutoreleasePoolKey] = JERThreadAutoreleasePoolKey;
}

@end
