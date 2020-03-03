//
//  UIApplication+JER_Custom.h
//  JERFrame
//
//  Created by super on 2018/11/20.
//  Copyright © 2018 Jeremy. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIApplication (JER_Custom)

@property (nullable, nonatomic, readonly) NSString * appBundleName;
@property (nullable, nonatomic, readonly) NSString * appBundleID;
@property (nullable, nonatomic, readonly) NSString * appVersion;
@property (nullable, nonatomic, readonly) NSString * appBuildVersion;

@property (nonatomic, readonly) BOOL isPirated;
@property (nonatomic, readonly) BOOL isBeingDebugged;

@property (nonatomic, readonly) uint64_t memoryUsage;
@property (nonatomic, readonly) float cpuUsage;

- (void)incrementNetworkActivityCount;
- (void)decrementNetworkActivityCount;

+ (BOOL)isAppExtension;
+ (nullable UIApplication *)sharedExtensionApplication;

@end

NS_ASSUME_NONNULL_END
