//
//  NSFileManager+MRD_Custom.m
//  JERFrame
//
//  Created by super on 2018/11/20.
//  Copyright © 2018 Jeremy. All rights reserved.
//

#import "NSFileManager+MRD_Custom.h"

@implementation NSFileManager (MRD_Custom)

+ (NSURL *)documentsURL {
    return [[[self defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

+ (NSString *)documentsPath {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
}

+ (NSURL *)cachesURL {
    return [[[self defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
}

+ (NSString *)cachesPath {
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
}

+ (NSURL *)libraryURL {
    return [[[self defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject];
}

+ (NSString *)libraryPath {
    return [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
}

@end
