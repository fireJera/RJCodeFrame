//
//  NSDictionary+JER_Custom.m
//  JERFrame
//
//  Created by super on 2018/11/21.
//  Copyright © 2018 Jeremy. All rights reserved.
//

#import "NSDictionary+JER_Custom.h"

@implementation NSDictionary (JER_Custom)

- (BOOL)containsObjectForKey:(id)key {
    if (!key) return NO;
    return self[key] != nil;
}

static NSNumber *NSNumberFromID(id value) {
    static NSCharacterSet * dot;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dot = [NSCharacterSet characterSetWithRange:NSMakeRange('.', 1)];
    });
    if (!value || value == [NSNull null]) return nil;
    if ([value isKindOfClass:[NSNumber class]]) return value;
    if ([value isKindOfClass:[NSString class]]) {
        NSString * lower = ((NSString *)value).lowercaseString;
        if ([lower isEqualToString:@"true"] || [lower isEqualToString:@"yes"]) return @(YES);
        if ([lower isEqualToString:@"false"] || [lower isEqualToString:@"no"]) return @(NO);
        if ([lower isEqualToString:@"nil"] || [lower isEqualToString:@"null"]) return nil;
        if ([(NSString *)value rangeOfCharacterFromSet:dot].location != NSNotFound) {
            return @(((NSString *)value).doubleValue);
        } else {
            return @(((NSString *)value).longLongValue);
        }
    }
    return nil;
}

#define RETURN_VALUE(_type_)                                            \
if (!key) return def;                                                   \
id value = self[key];                                                   \
if (!value || value == [NSNull null]) return def;                       \
if ([value isKindOfClass:[NSNumber class]]) return ((NSNumber *)value)._type_;                                                    \
if ([value isKindOfClass:[NSString class]]) return         NSNumberFromID(value)._type_;                                       \
return def;                                                             \

- (BOOL)boolValueForKey:(NSString *)key default:(BOOL)def {
    RETURN_VALUE(boolValue);
}

- (char)charValueForKey:(NSString *)key default:(char)def {
    RETURN_VALUE(charValue);
}

- (unsigned char)unsignedCharValueForKey:(NSString *)key default:(unsigned char)def {
    RETURN_VALUE(unsignedCharValue);
}

- (short)shortValueForKey:(NSString *)key default:(short)def {
    RETURN_VALUE(shortValue);
}

- (unsigned short)unsignedShortValueForKey:(NSString *)key default:(unsigned short)def {
    RETURN_VALUE(unsignedShortValue);
}

- (int)intValueForKey:(NSString *)key default:(int)def {
    RETURN_VALUE(intValue);
}

- (unsigned int)unsignedIntValueForKey:(NSString *)key default:(unsigned int)def {
    RETURN_VALUE(unsignedIntValue);
}

- (long)longValueForKey:(NSString *)key default:(long)def {
    RETURN_VALUE(longValue);
}

- (unsigned long)unsignedLongValueForKey:(NSString *)key default:(unsigned long)def {
    RETURN_VALUE(unsignedLongValue);
}

- (long long)longLongValueForKey:(NSString *)key default:(long long)def {
    RETURN_VALUE(longLongValue);
}

- (unsigned long long)unsignedLongLongValueForKey:(NSString *)key default:(unsigned long long)def {
    RETURN_VALUE(unsignedLongLongValue);
}

- (float)floatValueForKey:(NSString *)key default:(float)def {
    RETURN_VALUE(floatValue);
}

- (double)doubleValueForKey:(NSString *)key default:(double)def {
    RETURN_VALUE(doubleValue);
}

- (NSInteger)integerValueForKey:(NSString *)key default:(NSInteger)def {
    RETURN_VALUE(integerValue);
}

- (NSUInteger)unsignedIntegerValueForKey:(NSString *)key default:(NSUInteger)def {
    RETURN_VALUE(unsignedIntegerValue);
}

- (NSNumber *)numberValueForKey:(NSString *)key default:(NSNumber *)def {
    if (!key) return def;
    id value = self[key];
    if (!value || value == [NSNull null]) return def;
    if ([value isKindOfClass:[NSNumber class]]) return value;
    if ([value isKindOfClass:[NSString class]]) return NSNumberFromID(value);
    return def;
}

- (NSString *)stringValueForKey:(NSString *)key default:(NSString *)def {
    if (!key) return def;
    id value = self[key];
    if (!value || value == [NSNull null]) return def;
    if ([value isKindOfClass:[NSNumber class]]) return value;
    if ([value isKindOfClass:[NSString class]]) return ((NSNumber *)value).description;
    return def;
}

@end

@implementation NSMutableDictionary (JER_Custom)

- (id)popObjectForKey:(id)akey {
    if (!akey) return nil;
    id pop = self[akey];
    [self removeObjectForKey:akey];
    return pop;
}

- (NSDictionary *)popEntriesForKeys:(NSArray *)keys {
    NSMutableDictionary * dic = [NSMutableDictionary dictionary];
    if (!keys) return nil;
    for (id key in keys) {
        id value = self[key];
        if (value) {
            [dic setObject:value forKey:key];
            [self removeObjectForKey:key];
        }
    }
    return [dic copy];
}

@end
