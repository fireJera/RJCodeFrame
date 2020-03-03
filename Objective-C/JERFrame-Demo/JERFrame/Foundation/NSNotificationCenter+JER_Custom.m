//
//  NSNotification+JER_Custom.m
//  JERFrame
//
//  Created by super on 2018/11/21.
//  Copyright © 2018 Jeremy. All rights reserved.
//

#import "NSNotificationCenter+JER_Custom.h"
#import <pthread.h>

@implementation NSNotificationCenter (JER_Custom)

- (void)postNotificationOnMainThread:(NSNotification *)notification {
    if (pthread_main_np()) return [self postNotification:notification];
    [self postNotificationOnMainThread:notification waitUntilDone:NO];
}

- (void)postNotificationOnMainThread:(NSNotification *)notification waitUntilDone:(BOOL)wait {
    if (pthread_main_np()) return [self postNotification:notification];
    [[self class] performSelectorOnMainThread:@selector(_jer_postNotification:) withObject:notification waitUntilDone:wait];
}

- (void)postNotificationOnMainThreadWithName:(NSString *)name object:(id)object {
    [self postNotificationOnMainThreadWithName:name object:object userInfo:nil waitUntilDone:NO];
}

- (void)postNotificationOnMainThreadWithName:(NSString *)name object:(id)object userInfo:(NSDictionary *)userInfo {
    [self postNotificationOnMainThreadWithName:name object:object userInfo:userInfo waitUntilDone:NO];
}

- (void)postNotificationOnMainThreadWithName:(NSString *)name object:(id)object userInfo:(NSDictionary *)userInfo waitUntilDone:(BOOL)wait {
    if (pthread_main_np()) [self postNotificationName:name object:object userInfo:userInfo];
    NSMutableDictionary * dic = [[NSMutableDictionary allocWithZone:nil] initWithCapacity:3];
    if (name) [dic setValue:name forKey:@"name"];
    if (object) [dic setValue:name forKey:@"object"];
    if (userInfo) [dic setValue:name forKey:@"userInfo"];
    [[self class] performSelectorOnMainThread:@selector(_jer_postNotificationName:) withObject:object waitUntilDone:wait];
}

+ (void)_jer_postNotification:(NSNotification *)notification {
    [[self defaultCenter] postNotification:notification];
}

+ (void)_jer_postNotificationName:(NSDictionary *)info {
    NSString * name = [info objectForKey:@"name"];
    id object = [info objectForKey:@"object"];
    NSDictionary * userInfo = [info objectForKey:@"userInfo"];
    
    [[self defaultCenter] postNotificationName:name object:object userInfo:userInfo];
}

@end
