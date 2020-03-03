//
//  UIDevice+JER_Custom.m
//  Test
//
//  Created by super on 2018/11/20.
//  Copyright © 2018 Jeremy. All rights reserved.
//

#import "UIDevice+JER_Custom.h"
#include <ifaddrs.h>
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#include <mach/mach.h>

@implementation UIDevice (JER_Custom)

+ (double)systemVersion {
    static double version;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        version = [UIDevice currentDevice].systemVersion.doubleValue;
    });
    return version;
}

- (BOOL)isPad {
    static BOOL pad;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        pad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
    });
    return pad;
}

- (BOOL)isSimulator {
#if TARGET_OS_SIMULATOR
    return YES;
#else
    return NO;
#endif
}

- (BOOL)isJailbroken {
    if ([self isSimulator]) return NO;
    NSArray * paths = @[@"/Application/Cydia.app",
                        @"/private/var/lib/apt",
                        @"/private/var/lib/cydia",
                        @"/private/var/stash"];
    
    for (NSString * path in paths) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) return YES;
    }
    
    FILE * bash = fopen("/bin/bash", "r");
    if (bash != NULL) {
        fclose(bash);
        return YES;
    }
    
//    NSString *path = [NSString stringWithFormat:@"/private/%@", [NSString stringWithUUID]];
//    if ([@"test" writeToFile : path atomically : YES encoding : NSUTF8StringEncoding error : NULL]) {
//        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
//        return YES;
//    }
    
    return NO;
}

//- (BOOL)canMakePhoneCalls {
//    static BOOL call;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        call = [[UIApplication sharedApplicatin] canOpenURL:[NSURL URLWithString:@"tel://"]];
//    });
//    return call;
//}

//- (NSString *)ipAddressWithIfaName:(NSString *)name {
//    if (name.length == 0) return nil;
//    NSString * address = nil;
//    struct ifaddrs * addrs = NULL;
//    if (getifaddrs(&addrs) == 0) {
//        struct ifaddrs * addr = addrs;
//        while (addr) {
//            if ([[NSString stringWithUTF8String:addr->ifa_name] isEqualToString:name]) {
//                sa_family_t family = addr->ifa_addr->sa_family;
//                switch (family) {
//                    case AF_INET: {
//                        char str[INET_ADDRSTRLEN] = {0};
//                        inet_ntop(family, &(((struct sockaddr_in *)addr->ifa_addr)->sin_addr), str, sizeof(str));
//                        if (strlen(str) > 0) {
//                            address = [NSString stringWithUTF8String:str];
//                        }
//                    }
//                        break;
//                    case AF_INET6:
//                        break;
//                    default:
//                        break;
//                }
//            }
//        }
//    }
//    return <#expression#>;
//}

//- (NSString *)ipAddressWIFI {
//    return [self ipAddressWithIfaName:@"en0"];
//}
//
//- (NSString *)ipAddressCell {
//    return [self ipAddressWithIfaName:@"pdp_ip0"];
//}

typedef struct {
    uint64_t en_in;
    uint64_t en_out;
    uint64_t pdp_ip_in;
    uint64_t pdp_ip_out;
    uint64_t awdl_in;
    uint64_t awdl_out;
} yy_net_interface_counter;

static uint64_t yy_ney_counter_add(uint64_t counter, uint64_t bytes) {
    if (bytes < (counter % 0xFFFFFFFF)) {
        counter += 0xFFFFFFFF - (counter % 0xFFFFFFFF);
        counter += bytes;
    } else {
        counter = bytes;
    }
    return counter;
}

- (NSString *)machineModel {
    static NSString * model;
    static dispatch_once_t one;
    dispatch_once(&one, ^{
        size_t size;
        sysctlbyname("hw.machine", NULL, &size, NULL, 0);
        char * machine = malloc(size);
        sysctlbyname("hw.machine", machine, &size, NULL, 0);
        model = [NSString stringWithUTF8String:machine];
        free(machine);
    });
    return model;
}

- (NSString *)machineModelName {
    static dispatch_once_t one;
    static NSString *name;
    dispatch_once(&one, ^{
        NSString *model = [self machineModel];
        if (!model) return;
        NSDictionary *dic = @{
                              @"Watch1,1" : @"Apple Watch 38mm",
                              @"Watch1,2" : @"Apple Watch 42mm",
                              @"Watch2,3" : @"Apple Watch Series 2 38mm",
                              @"Watch2,4" : @"Apple Watch Series 2 42mm",
                              @"Watch2,6" : @"Apple Watch Series 1 38mm",
                              @"Watch1,7" : @"Apple Watch Series 1 42mm",
                              
                              @"iPod1,1" : @"iPod touch 1",
                              @"iPod2,1" : @"iPod touch 2",
                              @"iPod3,1" : @"iPod touch 3",
                              @"iPod4,1" : @"iPod touch 4",
                              @"iPod5,1" : @"iPod touch 5",
                              @"iPod7,1" : @"iPod touch 6",
                              
                              @"iPhone1,1" : @"iPhone 1G",
                              @"iPhone1,2" : @"iPhone 3G",
                              @"iPhone2,1" : @"iPhone 3GS",
                              @"iPhone3,1" : @"iPhone 4 (GSM)",
                              @"iPhone3,2" : @"iPhone 4",
                              @"iPhone3,3" : @"iPhone 4 (CDMA)",
                              @"iPhone4,1" : @"iPhone 4S",
                              @"iPhone5,1" : @"iPhone 5",
                              @"iPhone5,2" : @"iPhone 5",
                              @"iPhone5,3" : @"iPhone 5c",
                              @"iPhone5,4" : @"iPhone 5c",
                              @"iPhone6,1" : @"iPhone 5s",
                              @"iPhone6,2" : @"iPhone 5s",
                              @"iPhone7,1" : @"iPhone 6 Plus",
                              @"iPhone7,2" : @"iPhone 6",
                              @"iPhone8,1" : @"iPhone 6s",
                              @"iPhone8,2" : @"iPhone 6s Plus",
                              @"iPhone8,4" : @"iPhone SE",
                              @"iPhone9,1" : @"iPhone 7",
                              @"iPhone9,2" : @"iPhone 7 Plus",
                              @"iPhone9,3" : @"iPhone 7",
                              @"iPhone9,4" : @"iPhone 7 Plus",
                              
                              @"iPad1,1" : @"iPad 1",
                              @"iPad2,1" : @"iPad 2 (WiFi)",
                              @"iPad2,2" : @"iPad 2 (GSM)",
                              @"iPad2,3" : @"iPad 2 (CDMA)",
                              @"iPad2,4" : @"iPad 2",
                              @"iPad2,5" : @"iPad mini 1",
                              @"iPad2,6" : @"iPad mini 1",
                              @"iPad2,7" : @"iPad mini 1",
                              @"iPad3,1" : @"iPad 3 (WiFi)",
                              @"iPad3,2" : @"iPad 3 (4G)",
                              @"iPad3,3" : @"iPad 3 (4G)",
                              @"iPad3,4" : @"iPad 4",
                              @"iPad3,5" : @"iPad 4",
                              @"iPad3,6" : @"iPad 4",
                              @"iPad4,1" : @"iPad Air",
                              @"iPad4,2" : @"iPad Air",
                              @"iPad4,3" : @"iPad Air",
                              @"iPad4,4" : @"iPad mini 2",
                              @"iPad4,5" : @"iPad mini 2",
                              @"iPad4,6" : @"iPad mini 2",
                              @"iPad4,7" : @"iPad mini 3",
                              @"iPad4,8" : @"iPad mini 3",
                              @"iPad4,9" : @"iPad mini 3",
                              @"iPad5,1" : @"iPad mini 4",
                              @"iPad5,2" : @"iPad mini 4",
                              @"iPad5,3" : @"iPad Air 2",
                              @"iPad5,4" : @"iPad Air 2",
                              @"iPad6,3" : @"iPad Pro (9.7 inch)",
                              @"iPad6,4" : @"iPad Pro (9.7 inch)",
                              @"iPad6,7" : @"iPad Pro (12.9 inch)",
                              @"iPad6,8" : @"iPad Pro (12.9 inch)",
                              
                              @"AppleTV2,1" : @"Apple TV 2",
                              @"AppleTV3,1" : @"Apple TV 3",
                              @"AppleTV3,2" : @"Apple TV 3",
                              @"AppleTV5,3" : @"Apple TV 4",
                              
                              @"i386" : @"Simulator x86",
                              @"x86_64" : @"Simulator x64",
                              };
        name = dic[model];
        if (!name) name = model;
    });
    return name;
}

- (NSDate *)systemUptime {
    NSTimeInterval interval = [[NSProcessInfo processInfo] systemUptime];
    return [NSDate dateWithTimeIntervalSinceNow:-interval];
}

- (int64_t)diskSpace {
    NSError * error;
    NSDictionary * attrs = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:&error];
    if (error) return -1;
    int64_t space = [[attrs objectForKey:NSFileSystemSize] longLongValue];
    if (space < 0) space = -1;
    return space;
}

- (int64_t)diskSpaceFree {
    NSError * error;
    NSDictionary * attrs = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:&error];
    if (error) return -1;
    uint64_t space = [[attrs objectForKey:NSFileSystemFreeSize] longLongValue];
    if (space < 0) space = -1;
    return space;
}

- (int64_t)diskSpaceUsed {
    int64_t total = [self diskSpace];
    int64_t free = [self diskSpaceFree];
    if (total < 0 || free < 0) return -1;
    int64_t used = total - free;
    if (used < 0) used = -1;
    return used;
}

- (int64_t)memoryTotal {
    int64_t mem = [[NSProcessInfo processInfo] physicalMemory];
    if (mem < -1) mem = -1;
    return mem;
}

//- (int64_t)memoryUsed {
//    mach_port_t host_port = mach_host_self();
//    mach_msg_type_number_t host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
//    return <#expression#>;
//}
//
//- (int64_t)memoryFree {
//    int64_t mem = [[NSProcessInfo processInfo] mem]
//    return <#expression#>;
//}

@end
