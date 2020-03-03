//
//  UIApplication+JER_Custom.m
//  JERFrame
//
//  Created by super on 2018/11/20.
//  Copyright © 2018 Jeremy. All rights reserved.
//

#import "UIApplication+JER_Custom.h"
#import "UIDevice+JER_Custom.h"

@implementation UIApplication (JER_Custom)

- (BOOL)isPirated {
    if ([[UIDevice currentDevice] isSimulator]) return YES;
    if (getgid() == 10) return YES;
    if ([self _jer_fileExistsInMainBundle:@"SignerIdentity"]) {
        return YES;
    }
    
    if (![self _jer_fileExistsInMainBundle:@"_CodeSignature"]) {
        return YES;
    }
    if (![self _jer_fileExistsInMainBundle:@"SC_Info"]) {
        return YES;
    }
    return NO;
}

- (BOOL)_jer_fileExistsInMainBundle:(NSString *)name {
    NSString * bundlePath = [[NSBundle mainBundle] bundlePath];
    NSString * path = [NSString stringWithFormat:@"%@/%@", bundlePath, name];
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

- (NSString *)appBundleName {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
}

- (NSString *)appBundleID {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
}

- (NSString *)appVersion {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

- (NSString *)appBuildVersion {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
}

@end
