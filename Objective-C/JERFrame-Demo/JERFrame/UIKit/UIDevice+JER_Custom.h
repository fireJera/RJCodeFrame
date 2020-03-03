//
//  UIDevice+JER_Custom.h
//  Test
//
//  Created by super on 2018/11/20.
//  Copyright © 2018 Jeremy. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIDevice (JER_Custom)

#pragma mark - Device Information

+ (double)systemVersion;

@property (nonatomic, readonly) BOOL isPad;

@property (nonatomic, readonly) BOOL isSimulator;

@property (nonatomic, readonly) BOOL isJailbroken;

@property (nonatomic, readonly) BOOL canMakePhoneCalls NS_EXTENSION_UNAVAILABLE_IOS("");

@property (nullable, nonatomic, readonly) NSString * machineModel;

@property (nullable, nonatomic, readonly) NSString * machineModelName;

@property (nullable, nonatomic, readonly) NSDate * systemUptime;

#pragma mark - Network Infomation

@property (nullable, nonatomic, readonly) NSString * ipAddressWIFI;

@property (nullable, nonatomic, readonly) NSString * ipAddressCell;

typedef NS_OPTIONS(NSUInteger, JERNetworkTrafficType) {
    JERNetworkTrafficTypeWWANSent       = 1 << 0,
    JERNetworkTrafficTypeWWANReceived   = 1 << 1,
    JERNetworkTrafficTypeWIFISent       = 1 << 2,
    JERNetworkTrafficTypeWIFIReceived   = 1 << 3,
    JERNetworkTrafficTypeAWDLSent       = 1 << 4,
    JERNetworkTrafficTypeAWDLReceived   = 1 << 5,
    
    JERNetworkTrafficTypeWWAN   = JERNetworkTrafficTypeWWANSent | JERNetworkTrafficTypeWWANReceived,
    JERNetworkTrafficTypeWIFI   = JERNetworkTrafficTypeWIFISent | JERNetworkTrafficTypeWIFIReceived,
    JERNetworkTrafficTypeAWDL   = JERNetworkTrafficTypeAWDLSent | JERNetworkTrafficTypeAWDLReceived,
    JERNetworkTrafficTypeALL    = JERNetworkTrafficTypeWWAN | JERNetworkTrafficTypeWIFI | JERNetworkTrafficTypeAWDL,
};

- (uint64_t)getNewworkTrafficeBytes:(JERNetworkTrafficType)types;

#pragma mark - Disk Space

@property (nonatomic, readonly) int64_t diskSpace;

@property (nonatomic, readonly) int64_t diskSpaceFree;

@property (nonatomic, readonly) int64_t diskSpaceUsed;

#pragma mark - Memory Information

@property (nonatomic, readonly) int64_t memoryTotal;

@property (nonatomic, readonly) int64_t memoryUsed;

@property (nonatomic, readonly) int64_t memoryFree;

@property (nonatomic, readonly) int64_t memoryActive;

@property (nonatomic, readonly) int64_t memoryInactive;

@property (nonatomic, readonly) int64_t memoryWired;

@property (nonatomic, readonly) int64_t memoryPurgable;

#pragma mark - CPU Information

@property (nonatomic, readonly) NSUInteger cpuCount;

@property (nonatomic, readonly) float cpuUsage;

@property (nullable, nonatomic, readonly) NSArray<NSNumber *> * cpuUsagePerProcessor;

@end

NS_ASSUME_NONNULL_END

#ifndef kSystemVersion
#define kSystemVersion [UIDevice systemVersion];
#endif

#ifndef kiOS6Later
#define kiOS6Later (kSystemVersion >= 6);
#endif

#ifndef kiOS7Later
#define kiOS7Later (kSystemVersion >= 7);
#endif

#ifndef kiOS8Later
#define kiOS8Later (kSystemVersion >= 8);
#endif

#ifndef kiOS9Later
#define kiOS9Later (kSystemVersion >= 9);
#endif
