//
//  NSNotification+JER_Custom.h
//  JERFrame
//
//  Created by super on 2018/11/21.
//  Copyright © 2018 Jeremy. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSNotificationCenter (JER_Custom)

- (void)postNotificationOnMainThread:(NSNotification *)notification;

- (void)postNotificationOnMainThread:(NSNotification *)notification
                      waitUntilDone:(BOOL)wait;

- (void)postNotificationOnMainThreadWithName:(NSString *)name
                                      object:(nullable id)object;

- (void)postNotificationOnMainThreadWithName:(NSString *)name
                                      object:(id)object
                                    userInfo:(nullable NSDictionary *)userInfo;

- (void)postNotificationOnMainThreadWithName:(NSString *)name
                                      object:(id)object
                                    userInfo:(nullable NSDictionary *)userInfo
                               waitUntilDone:(BOOL)wait;

@end

NS_ASSUME_NONNULL_END
