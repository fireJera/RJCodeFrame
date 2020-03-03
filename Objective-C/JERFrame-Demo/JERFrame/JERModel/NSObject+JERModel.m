//
//  NSObject+JERModel.m
//  JERFrame
//
//  Created by super on 2018/11/21.
//  Copyright © 2018 Jeremy. All rights reserved.
//

#import "NSObject+JERModel.h"
#import "JERClassInfo.h"
#import <objc/message.h>

#define force_inline __inline__ __attribute__((always_inline))

typedef NS_ENUM(NSUInteger, JEREncodingNSType) {
    JEREncodingTypeNSUnknow = 0,
    JEREncodingTypeNSString,
    JEREncodingTypeNSMutableString,
    JEREncodingTypeNSValue,
    JEREncodingTypeNSNumber,
    JEREncodingTypeNSDecimalNumber,
    JEREncodingTypeNSData,
    JEREncodingTypeNSMutableData,
    JEREncodingTypeNSDate,
    JEREncodingTypeNSURL,
    JEREncodingTypeNSArray,
    JEREncodingTypeNSMutableArray,
    JEREncodingTypeNSDictionary,
    JEREncodingTypeNSMutableDictionary,
    JEREncodingTypeNSSet,
    JEREncodingTypeNSMutableSet,
};

static force_inline JEREncodingNSType JERClassGetNSType(Class cls) {
    if (!cls) return JEREncodingTypeNSUnknow;
    if ([cls isSubclassOfClass:[NSMutableString class]]) return JEREncodingTypeNSMutableString;
    if ([cls isSubclassOfClass:[NSString class]]) return JEREncodingTypeNSString;
    if ([cls isSubclassOfClass:[NSValue class]]) return JEREncodingTypeNSValue;
    if ([cls isSubclassOfClass:[NSNumber class]]) return JEREncodingTypeNSNumber;
    if ([cls isSubclassOfClass:[NSDecimalNumber class]]) return JEREncodingTypeNSDecimalNumber;
    if ([cls isSubclassOfClass:[NSData class]]) return JEREncodingTypeNSData;
    if ([cls isSubclassOfClass:[NSMutableData class]]) return JEREncodingTypeNSMutableData;
    if ([cls isSubclassOfClass:[NSDate class]]) return JEREncodingTypeNSDate;
    if ([cls isSubclassOfClass:[NSURL class]]) return JEREncodingTypeNSURL;
    if ([cls isSubclassOfClass:[NSArray class]]) return JEREncodingTypeNSArray;
    if ([cls isSubclassOfClass:[NSMutableArray class]]) return JEREncodingTypeNSMutableArray;
    if ([cls isSubclassOfClass:[NSDictionary class]]) return JEREncodingTypeNSDictionary;
    if ([cls isSubclassOfClass:[NSMutableDictionary class]]) return JEREncodingTypeNSMutableDictionary;
    if ([cls isSubclassOfClass:[NSSet class]]) return JEREncodingTypeNSSet;
    if ([cls isSubclassOfClass:[NSMutableSet class]]) return JEREncodingTypeNSMutableSet;
    return JEREncodingTypeNSUnknow;
}

static force_inline BOOL JEREncodingTypeIsCNumber(JEREncodingType type) {
    switch (type & JEREncodingTypeMask) {
        case JEREncodingTypeInt8:
        case JEREncodingTypeInt16:
        case JEREncodingTypeInt32:
        case JEREncodingTypeInt64:
        case JEREncodingTypeUInt8:
        case JEREncodingTypeUInt16:
        case JEREncodingTypeUInt32:
        case JEREncodingTypeUInt64:
        case JEREncodingTypeFloat:
        case JEREncodingTypeDouble:
        case JEREncodingTypeLongDouble: return YES;
        default: return NO;
    }
}

static force_inline NSNumber * JERNSNumberCreateFromID(__unsafe_unretained id value) {
    static NSCharacterSet * dot;
    static NSDictionary * dic;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dot = [NSCharacterSet characterSetWithRange:NSMakeRange('.', 1)];
        dic = @{@"TRUE":    @(YES),
                @"True":    @(YES),
                @"true":    @(YES),
                @"FALSE":   @(NO),
                @"False":   @(NO),
                @"false":   @(NO),
                @"YES":     @(YES),
                @"Yes":     @(YES),
                @"yes":     @(YES),
                @"NO":      @(NO),
                @"No":      @(NO),
                @"no":      @(NO),
                @"NIL":     (id)kCFNull,
                @"Nil":     (id)kCFNull,
                @"nil":     (id)kCFNull,
                @"NULL":    (id)kCFNull,
                @"Null":    (id)kCFNull,
                @"null":    (id)kCFNull,
                @"(NULL)":  (id)kCFNull,
                @"(Null)":  (id)kCFNull,
                @"(null)":  (id)kCFNull,
                @"<NULL>":  (id)kCFNull,
                @"<Null>":  (id)kCFNull,
                @"<null>":  (id)kCFNull,
                };
    });
    if (!value || value == (id)kCFNull) return nil;
    if ([value isKindOfClass:[NSNumber class]]) return value;
    if ([value isKindOfClass:[NSString class]]) {
        NSNumber * num = dic[value];
        if (num != nil) {
            if (num == (id)kCFNull) return nil;
            return num;
        }
        if ([(NSString *)value rangeOfCharacterFromSet:dot].location != NSNotFound) {
            const char * cstring = ((NSString *)value).UTF8String;
            if (!cstring) return nil;
            double num = atof(cstring);
            if (isnan(num) || isinf(num)) return nil;
            return @(num);
        } else {
            const char * cstring = ((NSString *)value).UTF8String;
            if (!cstring) return nil;
            return @(atoll(cstring));
        }
    }
    return nil;
}

static force_inline NSDate * JERNSDateFromString(__unsafe_unretained NSString *string) {
    typedef NSDate *(^JERNSDateParseBlock)(NSString * string);
#define kParseerNum 34
    static JERNSDateParseBlock blocks[kParseerNum + 1] = {0};
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        {
            /*
             2014-12-21 // Google
             */
            NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
            formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            formatter.dateFormat = @"yyyy-MM-dd";
            blocks[10] = ^(NSString * string){ return [formatter dateFromString:string]; };
        }
        {
            /*
             2014-01-10 12:33:33
             2014-01-10T12:33:33  //Google
             2014-01-10 12:33:33.000
             2014-01-10T12:33:33.000
             */
            NSDateFormatter * formatter1 = [[NSDateFormatter alloc] init];
            formatter1.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter1.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            formatter1.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
            
            NSDateFormatter * formatter2 = [[NSDateFormatter alloc] init];
            formatter1.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter1.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            formatter1.dateFormat = @"yyyy-MM-dd HH:mm:ss";
            
            NSDateFormatter * formatter3 = [[NSDateFormatter alloc] init];
            formatter1.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter1.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            formatter1.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS";
            
            NSDateFormatter * formatter4 = [[NSDateFormatter alloc] init];
            formatter1.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter1.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            formatter1.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
            
            blocks[19] = ^(NSString * string) {
                if ([string characterAtIndex:10] == 'T') {
                    return [formatter1 dateFromString:string];
                } else {
                    return [formatter2 dateFromString:string];
                }
            };
            
            blocks[23] = ^(NSString * string) {
                if ([string characterAtIndex:10] == 'T') {
                    return [formatter3 dateFromString:string];
                } else {
                    return [formatter4 dateFromString:string];
                }
            };
        }
        
        {
            /*
             2014-01-20T12:24:48Z        // Github, Apple
             2014-01-20T12:24:48+0800    // Facebook
             2014-01-20T12:24:48+12:00   // Google
             2014-01-20T12:24:48.000Z
             2014-01-20T12:24:48.000+0800
             2014-01-20T12:24:48.000+12:00
             */
            NSDateFormatter *formatter = [NSDateFormatter new];
            formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
            
            NSDateFormatter *formatter2 = [NSDateFormatter new];
            formatter2.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter2.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZ";
            
            blocks[20] = ^(NSString *string) { return [formatter dateFromString:string]; };
            blocks[24] = ^(NSString *string) { return [formatter dateFromString:string]?: [formatter2 dateFromString:string]; };
            blocks[25] = ^(NSString *string) { return [formatter dateFromString:string]; };
            blocks[28] = ^(NSString *string) { return [formatter2 dateFromString:string]; };
            blocks[29] = ^(NSString *string) { return [formatter2 dateFromString:string]; };
        }
        
        {
            /*
             Fri Sep 04 00:12:21 +0800 2015 // Weibo, Twitter
             Fri Sep 04 00:12:21.000 +0800 2015
             */
            NSDateFormatter *formatter = [NSDateFormatter new];
            formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter.dateFormat = @"EEE MMM dd HH:mm:ss Z yyyy";
            
            NSDateFormatter *formatter2 = [NSDateFormatter new];
            formatter2.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter2.dateFormat = @"EEE MMM dd HH:mm:ss.SSS Z yyyy";
            
            blocks[30] = ^(NSString *string) { return [formatter dateFromString:string]; };
            blocks[34] = ^(NSString *string) { return [formatter2 dateFromString:string]; };
        }
    });
    if (!string) return nil;
    if (string.length > kParseerNum) return nil;
    JERNSDateParseBlock parser = blocks[string.length];
    if (!parser) return nil;
    return parser(string);
#undef kParserNum
}

static force_inline Class JERNSBlockClass() {
    static Class cls;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        void(^block)(void) = ^{};
        cls = ((NSObject *)block).class;
        while (class_getSuperclass(cls) != [NSObject class]) {
            cls = class_getSuperclass(cls);
        }
    });
    return cls;
}

static force_inline NSDateFormatter *JERISODateFormatter() {
    static NSDateFormatter * formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
    });
    return formatter;
}

static force_inline id JERValueForKeyPath(__unsafe_unretained NSDictionary * dic, __unsafe_unretained NSArray *keyPaths) {
    id value = nil;
    for (NSUInteger i = 0, max = keyPaths.count; i < max; i++) {
        value = dic[keyPaths[i]];
        if (i + 1 < max) {
            if ([value isKindOfClass:[NSDictionary class]]) {
                dic = value;
            } else {
                return nil;
            }
        }
    }
    return value;
}

static force_inline id JERValueForMultiKeys(__unsafe_unretained NSDictionary * dic, __unsafe_unretained NSArray * multiKeys) {
    id value = nil;
    for (NSString * key in multiKeys) {
        if ([key isKindOfClass:[NSString class]]) {
            value = dic[key];
            if (value) break;
        } else {
            value = JERValueForKeyPath(dic, (NSArray *)key);
            if (value) break;
        }
    }
    return value;
}

@interface _JERModelPropertyMeta : NSObject {
    @package        // 在框架内是public 框架外是private
    NSString * _name;
    JEREncodingType _type;
    JEREncodingNSType _nsType;
    BOOL _isCNumber;
    Class _cls;
    Class _genericCls;
    SEL _getter;
    SEL _setter;
    BOOL _isKVCCompatible;
    BOOL _isStructAvailableForKeyedArchiver;
    BOOL _hasCustomClassFromDictionary;
    
    
    NSString * _mappedToKey;
    NSArray *_mappedToKeyPath;
    NSArray *_mappedToKeyArray;
    JERClassPropertyInfo *_info;
    _JERModelPropertyMeta *_next;
}

@end

@implementation _JERModelPropertyMeta

+ (instancetype)metaWithClassInfo:(JERClassInfo *)classInfo propertyInfo:(JERClassPropertyInfo *)propertyInfo generic:(Class)generic {
    if (!generic && propertyInfo.protocols) {
        for (NSString * protocol in propertyInfo.protocols) {
            Class cls = objc_getClass(protocol.UTF8String);
            if (cls) {
                generic = cls;
                break;
            }
        }
    }
    
    _JERModelPropertyMeta * meta = [self new];
    meta->_name = propertyInfo.name;
    meta->_type = propertyInfo.type;
    meta->_info = propertyInfo;
    meta->_genericCls = generic;
    
    if ((meta->_type & JEREncodingTypeMask) == JEREncodingTypeObject) {
        meta->_nsType = JERClassGetNSType(propertyInfo.cls);
    } else {
        meta->_isCNumber = JEREncodingTypeIsCNumber(meta->_type);
    }
    if ((meta->_type & JEREncodingTypeMask) == JEREncodingTypeStruct) {
        static NSSet * types = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSMutableSet * set = [NSMutableSet new];
            [set addObject:@"{CGSize=ff}"];
            [set addObject:@"{CGPoint=ff}"];
            [set addObject:@"{CGRect={CGSize=ff}{CGPoint=ff}}"];
            [set addObject:@"{CGAffineTransform=ffffff}"];
            [set addObject:@"{UIEdgeInsets=ffff}"];
            [set addObject:@"{UIOffset=ff}"];
            // 64 bit
            [set addObject:@"{CGSize=dd}"];
            [set addObject:@"{CGPoint=dd}"];
            [set addObject:@"{CGRect={CGSize=dd}{CGPoint=dd}}"];
            [set addObject:@"{CGAffineTransform=dddddd}"];
            [set addObject:@"{UIEdgeInsets=dddd}"];
            [set addObject:@"{UIOffset=dd}"];
            types = set;
        });
        if ([types containsObject:propertyInfo.typeEncoding]) {
            meta->_isStructAvailableForKeyedArchiver = YES;
        }
    }
    meta->_cls = propertyInfo.cls;
    
    if (generic) {
        meta->_hasCustomClassFromDictionary = [generic respondsToSelector:@selector(modelCustomClassForDictionary:)];
    } else if (meta->_cls && meta->_nsType == JEREncodingTypeUnknow) {
        meta->_hasCustomClassFromDictionary = [meta->_cls respondsToSelector:@selector(modelCustomClassForDictionary:)];
    }
    
    if (propertyInfo.getter) {
        if ([classInfo.cls instancesRespondToSelector:propertyInfo.getter]) {
            meta->_getter = propertyInfo.getter;
        }
    }
    if (propertyInfo.setter) {
        if ([classInfo.cls instancesRespondToSelector:propertyInfo.setter]) {
            meta->_setter = propertyInfo.setter;
        }
    }
    if (meta->_getter && meta->_setter) {
        switch (meta->_nsType & JEREncodingTypeMask) {
            case JEREncodingTypeBool:
            case JEREncodingTypeInt8:
            case JEREncodingTypeUInt8:
            case JEREncodingTypeInt16:
            case JEREncodingTypeUInt16:
            case JEREncodingTypeInt32:
            case JEREncodingTypeUInt32:
            case JEREncodingTypeInt64:
            case JEREncodingTypeUInt64:
            case JEREncodingTypeFloat:
            case JEREncodingTypeDouble:
            case JEREncodingTypeObject:
            case JEREncodingTypeClass:
            case JEREncodingTypeBlock:
            case JEREncodingTypeStruct:
            case JEREncodingTypeUnion:
                meta->_isKVCCompatible = YES;
                break;
            default:
                break;
        }
    }
    return meta;
}

@end

@interface _JERModelMeta : NSObject {
    @package
    JERClassInfo * _classInfo;
    NSDictionary * _mapper;
    NSArray * _allPropertyMetas;
    NSArray * _keyPathPropertyMetas;
    NSArray * _multiKeysPropertyMetas;
    NSUInteger _keyMappedCount;
    JEREncodingNSType _nsType;
    
    BOOL _hasCustomWillTransformDictionary;
    BOOL _hasCustomTransformFromDictionary;
    BOOL _hasCustomTransformToDictionary;
    BOOL _hasCustomClassFromDictionary;
}

@end

@implementation _JERModelMeta

- (instancetype)initWithClass:(Class)cls {
    JERClassInfo * classInfo = [JERClassInfo classInfoWithClass:cls];
    if (!classInfo) return nil;
    
    self = [super init];
    NSSet * blacklist = nil;
    if ([cls respondsToSelector:@selector(modelPropertyBlacklist)]) {
        NSArray * properties = [(id<JERModel>)cls modelPropertyBlacklist];
        blacklist = [NSSet setWithArray:properties];
    }
//    blacklist = [NSSet setWithArray:@[@"name", @"age"]];
    
    NSSet * whitelist = nil;
    if ([cls respondsToSelector:@selector(modelPropertyWhitelist)]) {
        NSArray * properties = [(id<JERModel>)cls modelPropertyWhitelist];
        whitelist = [NSSet setWithArray:properties];
    }
    //    whitelist = [NSSet setWithArray:@[@"name", @"age"]];
    
    NSDictionary * genericMapper = nil;
    if ([cls respondsToSelector:@selector(modelContainerPropertyGenericClass)]) {
        genericMapper = [(id<JERModel>)cls modelContainerPropertyGenericClass];
        if (genericMapper) {
            NSMutableDictionary * tmp = [NSMutableDictionary new];
            [genericMapper enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                if (![key isKindOfClass:[NSString class]]) return ;
                Class meta = object_getClass(obj);
                if (!meta) return;
                if (class_isMetaClass(meta)) {
                    tmp[key] = meta;
                } else if ([obj isKindOfClass:[NSString class]]) {
                    Class cls = NSClassFromString(obj);
                    if (cls) {
                        tmp[key] = cls;
                    }
                }
            }];
            genericMapper = tmp;
        }
    }
//    genericMapper = @[@"name", NSObject.class,
//                      @"age", NSNumber.class];
    
    NSMutableDictionary * allPropertyMetas = [NSMutableDictionary new];
    JERClassInfo * curClassInfo = classInfo;
    while (curClassInfo && curClassInfo.superCls != nil) {
        for (JERClassPropertyInfo * propertyInfo in curClassInfo.propertyInfos.allValues) {
            if (!propertyInfo.name) continue ;
            if (blacklist && [blacklist containsObject:propertyInfo.name]) continue;
            if (whitelist && ![whitelist containsObject:propertyInfo.name]) continue;
            _JERModelPropertyMeta * meta = [_JERModelPropertyMeta metaWithClassInfo:classInfo propertyInfo:propertyInfo generic:genericMapper[propertyInfo.name]];
            
            if (!meta || !meta->_name) continue;
            if (!meta->_getter || !meta->_setter) continue;
            if (allPropertyMetas[meta->_name]) continue;
            allPropertyMetas[meta->_name] = meta;
        }
        curClassInfo = classInfo.superClsInfo;
    }
    if (allPropertyMetas.count) _allPropertyMetas = allPropertyMetas.allValues.copy;
//    _allPropertyMetas = (NSArray<_JERModelPropertyMeta *> *)obj;
//    allPropertyMetas = @{@"name" : namePropertyMeta,
//                         @"age" : agePropertyMeta,
//                         };
    
    NSMutableDictionary * mapper = [NSMutableDictionary new];
    NSMutableArray * keyPathPropertyMetas = [NSMutableArray array];     //带点的 @"real.age"
    NSMutableArray * multiKeysPropertyMetas = [NSMutableArray array];
    if ([cls respondsToSelector:@selector(modelCustomPropertyMapper)]) {
        NSDictionary *customMapper = [(id<JERModel>)cls modelCustomPropertyMapper];
        [customMapper enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull propertyName, NSString * _Nonnull mappedToKey, BOOL * _Nonnull stop) {
            _JERModelPropertyMeta * propertyMeta = allPropertyMetas[propertyName];
            if (!propertyMeta) return;
            [allPropertyMetas removeObjectForKey:propertyName];
//            allPropertyMetas = @{@"pid": propertyMeta} mapper = @{@"id": propertyMeta}
            if ([mappedToKey isKindOfClass:[NSString class]]) {
                if (mappedToKey.length == 0) return;
                propertyMeta->_mappedToKey = mappedToKey;
                NSArray * keyPath = [mappedToKey componentsSeparatedByString:@"."];
                for (NSString * onePath in keyPath) {
                    if (onePath.length == 0) {
                        NSMutableArray * tmp = keyPath.copy;
                        [tmp removeObject:@""];
                        keyPath = tmp;
                        break;
                    }
                }
                if (keyPath.count > 1) {
                    propertyMeta->_mappedToKeyPath = keyPath;
                    [keyPathPropertyMetas addObject:propertyMeta];
                }
                propertyMeta->_next = mapper[mappedToKey]?: nil;
                mapper[mappedToKey] = propertyMeta;
            } else if ([mappedToKey isKindOfClass:[NSArray class]]) {
                NSMutableArray * mappedToKeyArray = [NSMutableArray array];
                for (NSString * oneKey in (NSArray *)mappedToKey) {
                    if (![oneKey isKindOfClass:[NSString class]]) continue;
                    if (oneKey.length == 0) continue;
                    
                    NSArray * keyPath = [oneKey componentsSeparatedByString:@"."];
                    if (keyPath.count > 1) {
                        [mappedToKeyArray addObject:keyPath];
                    } else {
                        [mappedToKeyArray addObject:oneKey];
                    }
                    // mappedToKeyArray = @[@"nickname", @"name", @"engName"];
                    if (!propertyMeta->_mappedToKey) {
                        propertyMeta->_mappedToKey = oneKey;
                        propertyMeta->_mappedToKeyPath = keyPath.count > 1 ? keyPath : nil;
                    }
                }
                if (!propertyMeta->_mappedToKey) return;
                
                propertyMeta->_mappedToKeyArray = mappedToKeyArray;
                [multiKeysPropertyMetas addObject:propertyMeta];
                
                propertyMeta->_next = mapper[mappedToKey] ? : nil;
                mapper[mappedToKey] = propertyMeta;
            }
        }];
    }
    
    [allPropertyMetas enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull name, _JERModelPropertyMeta * _Nonnull propertyMeta, BOOL * _Nonnull stop) {
        propertyMeta->_mappedToKey = name;
        propertyMeta->_next = mapper[name] ? : nil;
        mapper[name] = propertyMeta;
    }];
    
    if (mapper.count) _mapper = mapper;
    if (keyPathPropertyMetas) _keyPathPropertyMetas = keyPathPropertyMetas;
    if (multiKeysPropertyMetas) _multiKeysPropertyMetas = multiKeysPropertyMetas;
    
    _classInfo = classInfo;
    _keyMappedCount = _allPropertyMetas.count;
    _nsType = JERClassGetNSType(cls);
    _hasCustomWillTransformDictionary = ([cls instancesRespondToSelector:@selector(modelCustomWillTransformFromDictionary:)]);
    _hasCustomTransformFromDictionary = ([cls instancesRespondToSelector:@selector(modelCustomTranformFromDictionary:)]);
    _hasCustomTransformToDictionary = ([cls instancesRespondToSelector:@selector(modelCustomTranformFromDictionary:)]);
    _hasCustomClassFromDictionary = ([cls instancesRespondToSelector:@selector(modelCustomClassForDictionary:)]);
    return self;
}

+ (instancetype)metaWithClass:(Class)cls {
    if (!cls) return nil;
    static CFMutableDictionaryRef cache;
    static dispatch_once_t onceToken;
    static dispatch_semaphore_t lock;
    dispatch_once(&onceToken, ^{
        cache = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        lock = dispatch_semaphore_create(1);
    });
    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
    _JERModelMeta * meta = CFDictionaryGetValue(cache, (__bridge const void *)cls);
    dispatch_semaphore_signal(lock);
    if (!meta) {
        meta = [[self alloc] initWithClass:cls];
        if (meta) {
            dispatch_semaphore_wait(lock, 1);
            CFDictionarySetValue(cache, (__bridge const void *)cls, (__bridge const void *)meta);
            dispatch_semaphore_signal(lock);
        }
    }
    return meta;
}

@end

static force_inline NSNumber * ModelCreateNumberFromProperty(__unsafe_unretained id model,
                                                  __unsafe_unretained _JERModelPropertyMeta * meta) {
    switch (meta->_type & JEREncodingTypeMask) {
        case JEREncodingTypeBool:
            return @(((bool (*)(id, SEL))(void *) objc_msgSend)((id)model, meta->_getter));
        case JEREncodingTypeInt8:
            return @(((int8_t (*)(id, SEL))(void *) objc_msgSend)((id)model, meta->_getter));
        case JEREncodingTypeUInt8:
            return @(((uint8_t (*)(id, SEL))(void *) objc_msgSend)((id)model, meta->_getter));
        case JEREncodingTypeInt16:
            return @(((int16_t (*)(id, SEL))(void *) objc_msgSend)((id)model, meta->_getter));
        case JEREncodingTypeUInt16:
            return @(((uint16_t (*)(id, SEL))(void *) objc_msgSend)((id)model, meta->_getter));
        case JEREncodingTypeInt32:
            return @(((int32_t (*)(id, SEL))(void *) objc_msgSend)((id)model, meta->_getter));
        case JEREncodingTypeUInt32:
            return @(((uint32_t (*)(id, SEL))(void *) objc_msgSend)((id)model, meta->_getter));
        case JEREncodingTypeInt64: {
            return @(((int64_t (*)(id, SEL))(void *) objc_msgSend)((id)model, meta->_getter));
        }
        case JEREncodingTypeUInt64: {
            return @(((uint64_t (*)(id, SEL))(void *) objc_msgSend)((id)model, meta->_getter));
        }
        case JEREncodingTypeFloat: {
            float num = ((float (*)(id, SEL))(void *) objc_msgSend)((id)model, meta->_getter);
            //浮点数是否非数字 浮点数是否无限大
            if (isnan(num) || isinf(num)) return nil;
            return @(num);
        }
        case JEREncodingTypeDouble: {
            double num = ((double (*)(id, SEL))(void *) objc_msgSend)((id)model, meta->_getter);
            if (isnan(num) || isinf(num)) return nil;
            return @(num);
        }
        case JEREncodingTypeLongDouble: {
            double num = ((long double (*)(id, SEL))(void *) objc_msgSend)((id)model, meta->_getter);
            if (isnan(num) || isinf(num)) return nil;
            return @(num);
        }
        default: return nil;
    }
}

static force_inline void ModelSetNumberToProperty(__unsafe_unretained id model,
                                                  __unsafe_unretained NSNumber * num,
                                                  __unsafe_unretained _JERModelPropertyMeta * meta) {
    switch (meta->_type & JEREncodingTypeMask) {
        case JEREncodingTypeBool:
            ((void (*)(id, SEL, bool))(void *) objc_msgSend)((id)model, meta->_setter, num.boolValue);
            break;
        case JEREncodingTypeInt8:
            ((void (*)(id, SEL, int8_t))(void *) objc_msgSend)((id)model, meta->_setter, (int8_t)num.charValue);
            break;
        case JEREncodingTypeUInt8:
            ((void (*)(id, SEL, uint8_t))(void *) objc_msgSend)((id)model, meta->_setter, (uint8_t)num.unsignedCharValue);
            break;
        case JEREncodingTypeInt16:
            ((void (*)(id, SEL, int16_t))(void *) objc_msgSend)((id)model, meta->_setter, (int16_t)num.shortValue);
            break;
        case JEREncodingTypeUInt16:
            ((void (*)(id, SEL, uint16_t))(void *) objc_msgSend)((id)model, meta->_setter, (uint16_t)num.unsignedShortValue);
            break;
        case JEREncodingTypeInt32:
            ((void (*)(id, SEL, int32_t))(void *) objc_msgSend)((id)model, meta->_setter, (int32_t)num.intValue);
            break;
        case JEREncodingTypeUInt32:
            ((void (*)(id, SEL, uint32_t))(void *) objc_msgSend)((id)model, meta->_setter, (uint32_t)num.unsignedIntValue);
            break;
        case JEREncodingTypeInt64: {
            if ([num isKindOfClass:[NSDecimalNumber class]]) {
                ((void (*)(id, SEL, int64_t))(void *) objc_msgSend)((id)model, meta->_setter, (int64_t)num.stringValue.longLongValue);
            } else {
                ((void (*)(id, SEL, uint64_t))(void *) objc_msgSend)((id)model, meta->_setter, (uint64_t)num.unsignedLongLongValue);
            }
        }
            break;
        case JEREncodingTypeUInt64: {
            if ([num isKindOfClass:[NSDecimalNumber class]]) {
                ((void (*)(id, SEL, int64_t))(void *) objc_msgSend)((id)model, meta->_setter, (int64_t)num.stringValue.longLongValue);
            } else {
                ((void (*)(id, SEL, uint64_t))(void *) objc_msgSend)((id)model, meta->_setter, (uint64_t)num.unsignedLongLongValue);
            }
            
        }
            break;
        case JEREncodingTypeFloat: {
            float f = num.floatValue;
            //浮点数是否非数字 浮点数是否无限大
            if (isnan(f) || isinf(f)) f = 0;
            ((void (*)(id, SEL, float))(void *) objc_msgSend)((id)model, meta->_setter, f);
        }
            break;
        case JEREncodingTypeDouble: {
            double d = num.doubleValue;
            if (isnan(d) || isinf(d)) d = 0;
            ((void (*)(id, SEL, double))(void *) objc_msgSend)((id)model, meta->_setter, d);
        }
            break;
        case JEREncodingTypeLongDouble: {
            long double d = num.doubleValue;
            if (isnan(d) || isinf(d)) d = 0;
            ((void (*)(id, SEL, long double))(void *) objc_msgSend)((id)model, meta->_setter, (long double)d);
        }
            break;
        default:
            break;
    }
}

static void ModelSetValueForProperty(__unsafe_unretained id model,
                                     __unsafe_unretained id value,
                                     __unsafe_unretained _JERModelPropertyMeta * meta) {
    if (meta->_isCNumber) {
        NSNumber * num = JERNSNumberCreateFromID(value);
        ModelSetNumberToProperty(model, num, meta);
        if (num != nil) [num class];
    } else if (meta->_nsType) {
        if (value == (id)kCFNull) {
            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, (id)nil);
        } else {
            switch (meta->_nsType) {
                case JEREncodingTypeNSString:
                case JEREncodingTypeNSMutableString: {
                    if ([value isKindOfClass:[NSString class]]) {
                        if (meta->_nsType == JEREncodingTypeNSString) {
                            ((void (*)(id, SEL, id))(void *)objc_msgSend)((id)model, meta->_setter, value);
                        } else {
                            ((void (*)(id, SEL, id))(void *)objc_msgSend)((id)model, meta->_setter, ((NSString *)value).mutableCopy);
                        }
                    }
                    else if ([value isKindOfClass:[NSNumber class]]) {
                        ((void (*)(id, SEL, id))(void *)objc_msgSend)((id)model, meta->_setter, (meta->_nsType == JEREncodingTypeNSString ? ((NSNumber *)value).stringValue : ((NSNumber *)value).stringValue.mutableCopy));
                    }
                    else if ([value isKindOfClass:[NSData class]]) {
                        NSMutableString * string = [[NSMutableString alloc] initWithData:value encoding:NSUTF8StringEncoding];
                        ((void (*)(id, SEL, id))(void *)objc_msgSend)((id)model, meta->_setter, string);
                    }
                    else if ([value isKindOfClass:[NSURL class]]) {
                        ((void (*)(id, SEL, id))(void *)objc_msgSend)((id)model, meta->_setter, (meta->_nsType == JEREncodingTypeNSString ? ((NSURL *)value).absoluteString : ((NSURL *)value).absoluteString.mutableCopy));
                    } else if ([value isKindOfClass:[NSAttributedString class]]) {
                        ((void (*)(id, SEL, id))(void *)objc_msgSend)((id)model, meta->_setter, (meta->_nsType == JEREncodingTypeNSString ? ((NSAttributedString *)value).string : ((NSAttributedString *)value).string.mutableCopy));
                    }
                }
                    break;
                case JEREncodingTypeNSValue:
                case JEREncodingTypeNSNumber:
                case JEREncodingTypeNSDecimalNumber: {
                    if (meta->_nsType == JEREncodingTypeNSNumber) {
                        ((void (*)(id, SEL, id))(void *)objc_msgSend)((id)model, meta->_setter, JERNSNumberCreateFromID(value));
                    } else if (meta->_nsType == JEREncodingTypeNSDecimalNumber) {
                        if ([value isKindOfClass:[NSDecimalNumber class]]) {
                            ((void (*)(id, SEL, id))(void *)objc_msgSend)((id)model, meta->_setter, value);
                        } else if ([value isKindOfClass:[NSNumber class]]) {
                            NSDecimalNumber *decNum = [NSDecimalNumber decimalNumberWithDecimal:[((NSNumber *)value) decimalValue]];
                            ((void (*)(id, SEL, id))(void *)objc_msgSend)((id)model, meta->_setter, decNum);
                        } else if ([value isKindOfClass:[NSString class]]) {
                            NSDecimalNumber * num = [NSDecimalNumber decimalNumberWithString:value];
                            NSDecimal dec = num.decimalValue;
                            if (dec._length == 0 && dec._isNegative) {
                                num = nil;
                            }
                            ((void (*)(id, SEL, id))(void *)objc_msgSend)((id)model, meta->_setter, num);
                        }
                    } else {
                        if ([value isKindOfClass:[NSValue class]]) {
                            ((void (*)(id, SEL, id))(void *)objc_msgSend)((id)model, meta->_setter, value);
                        }
                    }
                }
                    break;
                case JEREncodingTypeNSData:
                case JEREncodingTypeNSMutableData: {
                    if ([value isKindOfClass:[NSData class]]) {
                        if (meta->_nsType == JEREncodingTypeNSData) {
                            ((void(*)(id, SEL, id))(void *)objc_msgSend)((id)model, meta->_setter, value);
                        } else {
                            ((void(*)(id, SEL, id))(void *)objc_msgSend)((id)model, meta->_setter, ((NSData *)value).mutableCopy);
                        }
                    } else if ([value isKindOfClass:[NSString class]]) {
                        NSData * data = [(NSString *)value dataUsingEncoding:NSUTF8StringEncoding];
                        if (meta->_nsType == JEREncodingTypeNSMutableData) {
                            data = ((NSData *)data).mutableCopy;
                        }
                        ((void(*)(id, SEL, id))(void *)objc_msgSend)((id)model, meta->_setter, data);
                    }
                }
                    break;
                case JEREncodingTypeNSDate: {
                    if ([value isKindOfClass:[NSDate class]]) {
                        ((void(*)(id, SEL, id))(void *)objc_msgSend)((id)model, meta->_setter, value);
                    } else if ([value isKindOfClass:[NSString class]]) {
                        ((void(*)(id, SEL, id))(void *)objc_msgSend)((id)model, meta->_setter, JERNSDateFromString(value));
                    }
                }
                    break;
                case JEREncodingTypeNSURL: {
                    if ([value isKindOfClass:[NSURL class]]) {
                        ((void(*)(id, SEL, id))(void *)objc_msgSend)((id)model, meta->_setter, value);
                    } else if ([value isKindOfClass:[NSString class]]) {
                        NSCharacterSet * set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
                        NSString * str = [value stringByTrimmingCharactersInSet:set];
                        if (str.length == 0) {
                            ((void(*)(id, SEL, id))(void *)objc_msgSend)((id)model, meta->_setter, nil);
                        } else {
                            NSURL * url = [NSURL URLWithString:(NSString *)value];
                            ((void(*)(id, SEL, id))(void *)objc_msgSend)((id)model, meta->_setter, url);
                        }
                    }
                }
                    break;
                case JEREncodingTypeNSArray:
                case JEREncodingTypeNSMutableArray: {
                    if (meta->_genericCls) {
                        NSArray * valueArr = nil;
                        if ([value isKindOfClass:[NSArray class]]) valueArr = value;
                        else if ([value isKindOfClass:[NSSet class]]) valueArr = ((NSSet *)value).allObjects;
                        if (valueArr) {
                            NSMutableArray * objectArr = [NSMutableArray array];
                            for (id one in valueArr) {
                                if ([one isKindOfClass:meta->_genericCls]) {
                                    [objectArr addObject:one];
                                } else if ([one isKindOfClass:[NSDictionary class]]) {
                                    Class cls = meta->_genericCls;
                                    if (meta->_hasCustomClassFromDictionary) {
                                        cls = [cls modelCustomClassForDictionary:one];
                                        if (!cls) cls = meta->_genericCls;
                                    }
                                    NSObject * newOne = [cls new];
                                    [newOne modelSetWithDictionary:one];
                                    if (newOne) [objectArr addObject:newOne];
                                }
                            }
                            ((void(*)(id, SEL, id))(void *)objc_msgSend)((id)model, meta->_setter, objectArr);
                        }
                    } else {
                        if ([value isKindOfClass:[NSArray class]]) {
                            if (meta->_nsType == JEREncodingTypeNSArray) {
                                ((void(*)(id, SEL, id))(void *)objc_msgSend)((id)model, meta->_setter, value);
                            } else {
                                ((void(*)(id, SEL, id))(void *)objc_msgSend)((id)model, meta->_setter, ((NSArray *)value).mutableCopy);
                            }
                        } else if ([value isKindOfClass:[NSSet class]]) {
                            if (meta->_nsType == JEREncodingTypeNSArray) {
                                ((void(*)(id, SEL, id))(void *)objc_msgSend)((id)model, meta->_setter, ((NSSet *)value).allObjects);
                            } else {
                                ((void(*)(id, SEL, id))(void *)objc_msgSend)((id)model, meta->_setter, ((NSSet *)value).allObjects.mutableCopy);
                            }
                        }
                    }
                }
                    break;
                case JEREncodingTypeNSDictionary:
                case JEREncodingTypeNSMutableDictionary: {
                    if ([value isKindOfClass:[NSDictionary class]]) {
                        if (meta->_genericCls) {
                            NSMutableDictionary * dic = [NSMutableDictionary dictionary];
                            [(NSDictionary *)value enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull oneKey, id  _Nonnull oneValue, BOOL * _Nonnull stop) {
                                if ([oneValue isKindOfClass:[NSDictionary class]]) {
                                    Class cls = meta->_genericCls;
                                    if (meta->_hasCustomClassFromDictionary) {
                                        cls = [cls modelCustomClassForDictionary:oneValue];
                                        if (!cls) cls = meta->_genericCls;
                                    }
                                    NSObject *newOne = [cls new];
                                    [newOne modelSetWithDictionary:(id)oneValue];
                                    if (newOne) dic[oneKey] = newOne;
                                }
                            }];
                            ((void(*)(id, SEL, id))(void *)objc_msgSend)((id)model, meta->_setter, dic);
                        } else {
                            if (meta->_nsType == JEREncodingTypeNSDictionary) {
                                ((void(*)(id, SEL, id))(void *)objc_msgSend)((id)model, meta->_setter, value);
                            } else {
                                ((void(*)(id, SEL, id))(void *)objc_msgSend)((id)model, meta->_setter, ((NSDictionary *)value).mutableCopy);
                            }
                        }
                    }
                }
                    break;
                case JEREncodingTypeNSSet:
                case JEREncodingTypeNSMutableSet: {
                    NSSet * valueSet = nil;
                    if ([value isKindOfClass:[NSArray class]]) valueSet = [NSSet setWithArray:value];
                    else if ([value isKindOfClass:[NSSet class]]) valueSet = ((NSSet *)value);
                    
                    if (meta->_genericCls) {
                        NSMutableSet * set = [NSMutableSet set];
                        for (id one in valueSet) {
                            if ([one isKindOfClass:meta->_genericCls]) {
                                [set addObject:one];
                            } else if ([one isKindOfClass:[NSDictionary class]]) {
                                Class cls = meta->_genericCls;
                                if (meta->_hasCustomClassFromDictionary) {
                                    cls = [cls modelCustomClassForDictionary:(NSDictionary *)one];
                                    if (!cls) cls = meta->_genericCls;
                                }
                                NSObject * newOne = [cls new];
                                [newOne modelSetWithDictionary:one];
                                if (newOne) [set addObject:newOne];
                            }
                        }
                        ((void(*)(id, SEL, id))(void *)objc_msgSend)((id)model, meta->_setter, set);
                    } else {
                        if (meta->_nsType == JEREncodingTypeNSSet) {
                            ((void(*)(id, SEL, id))(void *)objc_msgSend)((id)model, meta->_setter, valueSet);
                        } else {
                            ((void(*)(id, SEL, id))(void *)objc_msgSend)((id)model, meta->_setter, ((NSSet *)value).mutableCopy);
                        }
                    }
                }
                    break;
                case JEREncodingTypeNSUnknow:
                    break;
                default:
                    break;
            }
        }
    } else {
        BOOL isNull = (value == (id)kCFNull);
        switch (meta->_type & JEREncodingTypeMask) {
            case JEREncodingTypeObject: {
                Class cls = meta->_genericCls ? : meta->_cls;
                if (isNull) {
                    ((void(*)(id, SEL, id))(void *)objc_msgSend)((id)model, meta->_setter, (id)nil);
                } else if ([value isKindOfClass:cls] || !cls) {
                    ((void(*)(id, SEL, id))(void *)objc_msgSend)((id)model, meta->_setter, (id)value);
                } else if ([value isKindOfClass:[NSDictionary class]]) {
                    NSObject * one = nil;
                    if (meta->_getter) {
                        one = ((id (*)(id, SEL))(void *)objc_msgSend)((id)model, meta->_getter);
                    }
                    if (one) {
                        [one modelSetWithDictionary:value];
                    } else {
                        if (meta->_hasCustomClassFromDictionary) {
                            cls = [cls modelCustomClassForDictionary:value] ? : cls;
                        }
                        one = [cls new];
                        [one modelSetWithDictionary:value];
                        ((void(*)(id, SEL, id))(void *)objc_msgSend)((id)model, meta->_setter, (id)one);
                    }
                }
            }
                break;
            case JEREncodingTypeClass: {
                if (isNull) {
                    ((void(*)(id, SEL, Class))(void *)objc_msgSend)((id)model, meta->_setter, (Class)NULL);
                } else {
                    Class cls = nil;
                    if ([value isKindOfClass:[NSString class]]) {
                        cls = NSClassFromString(value);
                        if (cls) {
                            ((void(*)(id, SEL, Class))(void *)objc_msgSend)((id)model, meta->_setter, (Class)cls);
                        }
                    } else {
                        cls = object_getClass(value);
                        if (cls) {
                            if (class_isMetaClass(cls)) {
                                ((void(*)(id, SEL, Class))(void *)objc_msgSend)((id)model, meta->_setter, (Class)value);
                            }
                        }
                    }
                }
            }
                break;
            case JEREncodingTypeSEL: {
                if (isNull) {
                    ((void(*)(id, SEL, SEL))(void *)objc_msgSend)((id)model, meta->_setter, (SEL)NULL);
                } else if ([value isKindOfClass:[NSString class]]) {
                    SEL sel = NSSelectorFromString(value);
                    ((void(*)(id, SEL, SEL))(void *)objc_msgSend)((id)model, meta->_setter, (SEL)sel);
                }
            }
                break;
            case JEREncodingTypeBlock: {
                if (isNull) {
                    ((void(*)(id, SEL, void(^)(void)))(void *)objc_msgSend)((id)model, meta->_setter, (void(^)(void))NULL);
                } else if ([value isKindOfClass:JERNSBlockClass()]) {
                    ((void(*)(id, SEL, void(^)(void)))(void *)objc_msgSend)((id)model, meta->_setter, (void(^)(void))value);
                }
            }
                break;
            case JEREncodingTypeStruct:
            case JEREncodingTypeUnion:
            case JEREncodingTypeCArray: {
                if ([value isKindOfClass:[NSValue class]]) {
                    const char * valueType = ((NSValue *)value).objCType;
                    const char * metaType = meta->_info.typeEncoding.UTF8String;
                    if (valueType && metaType && strcmp(valueType, metaType) == 0) {
                        [model setValue:value forKey:meta->_name];
                    }
                }
            }
                break;
            case JEREncodingTypePointer:
            case JEREncodingTypeCString: {
                if (isNull) {
                    ((void(*)(id, SEL, void *))(void *)objc_msgSend)((id)model, meta->_setter, (void *)NULL);
                } else if ([value isKindOfClass:[NSValue class]]) {
                    NSValue * nsValue = value;
                    if (nsValue.objCType && strcmp(nsValue.objCType, "^") == 0) {
                        ((void(*)(id, SEL, void *))(void *)objc_msgSend)((id)model, meta->_setter, nsValue.pointerValue);
                    }
                }
            }
                break;
            default:
                break;
        }
    }
}

typedef struct {
    void *modelMeta;
    void *model;
    void *dictionary;
} ModelSetContext;

static void ModelSetWithDictionaryFunction(const void *_key, const void *_value, void *_context) {
    ModelSetContext * context = _context;
    __unsafe_unretained _JERModelMeta * meta = (__bridge _JERModelMeta *)(context->modelMeta);
    __unsafe_unretained _JERModelPropertyMeta * propertyMeta = [meta->_mapper objectForKey:(__bridge id)(_key)];
    __unsafe_unretained id model = (__bridge id)(context->model);
    while (propertyMeta) {
        if (propertyMeta->_setter) {
            ModelSetValueForProperty(model, (__bridge __unsafe_unretained id)_value, propertyMeta);
        }
        propertyMeta = propertyMeta->_next;
    };
}

static void ModelSetWithPropertyMetaArrayFunction(const void * _propertyMeta, void * _context) {
    ModelSetContext *context = _context;
    __unsafe_unretained NSDictionary * dictionary = (__bridge NSDictionary *)(context->dictionary);
    __unsafe_unretained _JERModelPropertyMeta * propertyMeta = (__bridge _JERModelPropertyMeta *)(_propertyMeta);
    if (!propertyMeta->_setter) return;
    id value = nil;
    
    if (propertyMeta->_mappedToKeyArray) {
        value = JERValueForMultiKeys(dictionary, propertyMeta->_mappedToKeyArray);
    } else if (propertyMeta->_mappedToKeyPath) {
        value = JERValueForKeyPath(dictionary, propertyMeta->_mappedToKeyPath);
    } else {
        value = [dictionary objectForKey:propertyMeta->_mappedToKey];
    }
    
    if (value) {
        __unsafe_unretained id model = (__bridge id)(context->model);
        ModelSetValueForProperty(model, value, propertyMeta);
    }
}

static id ModelToJSONObjectRecursive(NSObject *model) {
    if (!model || model == (id)kCFNull) return model;
    if ([model isKindOfClass:[NSString class]]) return model;
    if ([model isKindOfClass:[NSNumber class]]) return model;
    if ([model isKindOfClass:[NSDictionary class]]) {
        if ([NSJSONSerialization isValidJSONObject:model]) return model;
        NSMutableDictionary * newDic = [NSMutableDictionary dictionary];
        [(NSDictionary *)model enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            NSString *stringKey = [key isKindOfClass:[NSString class]] ? key : key.description;
            if (!stringKey) return ;
            id jsonObj = ModelToJSONObjectRecursive(obj);
            if (!jsonObj) jsonObj = (id)kCFNull;
            newDic[stringKey] = jsonObj;
        }];
        return newDic;
    }
    if ([model isKindOfClass:[NSSet class]]) {
        NSArray * array = ((NSSet *)model).allObjects;
        if ([NSJSONSerialization isValidJSONObject:array]) return array;
        NSMutableArray * newArray = [NSMutableArray array];
        for (id obj in array) {
            if ([obj isKindOfClass:[NSString class]] || [obj isKindOfClass:[NSNumber class]]) {
                [newArray addObject:obj];
            } else {
                id jsonObj = ModelToJSONObjectRecursive(obj);
                if (jsonObj && jsonObj != (id)kCFNull) [newArray addObject:jsonObj];
            }
        }
        return newArray;
    }
    if ([model isKindOfClass:[NSArray class]]) {
        if ([NSJSONSerialization isValidJSONObject:model]) return model;
        NSMutableArray * newArray = [NSMutableArray array];
        for (id obj in (NSArray *)model) {
            if ([obj isKindOfClass:[NSNumber class]] || [obj isKindOfClass:[NSString class]]) {
                [newArray addObject:obj];
            } else {
                id jsonObj = ModelToJSONObjectRecursive(obj);
                if (jsonObj && jsonObj != (id)kCFNull) [newArray addObject:jsonObj];
            }
        }
        return newArray;
    }
    if ([model isKindOfClass:[NSURL class]]) return ((NSURL *)model).absoluteString;
    if ([model isKindOfClass:[NSAttributedString class]]) return ((NSAttributedString *)model).string;
    if ([model isKindOfClass:[NSDate class]]) return [JERISODateFormatter() stringFromDate:(NSDate *)model];
    if ([model isKindOfClass:[NSData class]]) return nil;
    
    _JERModelMeta * modelMeta = [_JERModelMeta metaWithClass:[model class]];
    if (!modelMeta || modelMeta->_keyMappedCount == 0) return nil;
    NSMutableDictionary * result = [[NSMutableDictionary alloc] initWithCapacity:64];
    __unsafe_unretained NSMutableDictionary * dic = result;
    [modelMeta->_mapper enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull propertyMappedKey, _JERModelPropertyMeta * _Nonnull propertyMeta, BOOL * _Nonnull stop) {
        if (!propertyMeta->_getter) return ;
        id value = nil;
        if (propertyMeta->_isCNumber) {
            value = ModelCreateNumberFromProperty(model, propertyMeta);
        } else if (propertyMeta->_nsType) {
            id v = ((id (*)(id, SEL))(void * )objc_msgSend)((id)model, propertyMeta->_getter);
            value = ModelToJSONObjectRecursive(v);
            if (value == (id)kCFNull) value = nil;
        } else {
            switch (propertyMeta->_type & JEREncodingTypeMask) {
                case JEREncodingTypeObject: {
                    id v = ((id (*)(id, SEL))(void *)objc_msgSend)((id)model, propertyMeta->_getter);
                    value = ModelToJSONObjectRecursive(v);
                    if (value == (id)kCFNull) value = nil;
                }
                    break;
                case JEREncodingTypeClass: {
                    Class v = ((Class (*)(id, SEL))(void *)objc_msgSend)((id)model, propertyMeta->_getter);
                    value = v ? NSStringFromClass(v) : nil;
                }
                case JEREncodingTypeSEL: {
                    SEL v = ((SEL (*)(id, SEL))(void *)objc_msgSend)((id)model, propertyMeta->_getter);
                    value = v ? NSStringFromSelector(v) : nil;
                }
                default:
                    break;
            }
        }
        if (!value) return;
        
        if (propertyMeta->_mappedToKeyPath) {
            NSMutableDictionary * superDic = dic;
            NSMutableDictionary * subDic = nil;
            for (NSUInteger i = 0, max = propertyMeta->_mappedToKeyPath.count; i < max; i++) {
                NSString * key = propertyMeta->_mappedToKeyPath[i];
                if (i + 1 == max) {
                    if (!superDic[key]) superDic[key] = value;
                    break;
                }
                subDic = superDic[key];
                if (subDic) {
                    if ([subDic isKindOfClass:[NSDictionary class]]) {
                        subDic = subDic.mutableCopy;
                        subDic[key] = value;
                    } else {
                        break;
                    }
                } else {
                    subDic = [NSMutableDictionary dictionary];
                    subDic[key] = value;
                }
                superDic = subDic;
                subDic = nil;
            }
        } else {
            if (!dic[propertyMeta->_mappedToKey]) {
                dic[propertyMeta->_mappedToKey] = value;
            }
        }
    }];
    
    if (modelMeta->_hasCustomTransformToDictionary) {
        BOOL suc = [((id<JERModel>)model) modelCustomTranformToDictionary:dic];
        if (!suc) return nil;
    }
    return result;
}

static NSMutableString * ModelDescriptionAddIndent(NSMutableString *desc, NSUInteger indent) {
    for (NSUInteger i = 0, max = desc.length; i < max; i++) {
        unichar c = [desc characterAtIndex:i];
        if (c == '\n') {
            for (NSUInteger j = 0; j < indent; j++) {
                [desc insertString:@"    " atIndex:i + 1];
            }
            i += indent * 4;
            max += indent * 4;
        }
    }
    return desc;
}

static NSString *ModelDescription(NSObject *model) {
    static const int kMaxLength = 100;
    if (!model) return @"nil";
    if (model == (id)kCFNull) return @"null";
    if ([model isKindOfClass:[NSObject class]]) return [NSString stringWithFormat:@"%@", model];
    
    _JERModelMeta * modelMeta = [_JERModelMeta metaWithClass:model.class];
    switch (modelMeta->_nsType) {
        case JEREncodingTypeNSString:
        case JEREncodingTypeNSMutableString: {
            return [NSString stringWithFormat:@"\"%@\"", model];
        }
        case JEREncodingTypeNSValue:
        case JEREncodingTypeNSData:
        case JEREncodingTypeNSMutableData: {
            NSString * tmp = model.description;
            if (tmp.length > kMaxLength) {
                tmp = [tmp substringToIndex:kMaxLength];
                tmp = [tmp stringByAppendingString:@"..."];
            }
            return tmp;
        }
        case JEREncodingTypeNSNumber:
        case JEREncodingTypeNSDecimalNumber:
        case JEREncodingTypeNSDate:
        case JEREncodingTypeNSURL: {
            return [NSString stringWithFormat:@"%@", model];
        }
        case JEREncodingTypeNSSet:
        case JEREncodingTypeNSMutableSet: {
            model = ((NSSet *)model).allObjects;
        }
        case JEREncodingTypeNSArray:
        case JEREncodingTypeNSMutableArray: {
            NSArray * array = (id)model;
            NSMutableString * desc = [NSMutableString new];
            if (array.count == 0) {
                return [desc stringByAppendingString:@"[]"];
            } else {
                [desc appendFormat:@"[\n"];
                for (NSUInteger i = 0, max = array.count; i < max; i++) {
                    NSObject * obj = array[i];
                    [desc appendString:@"    "];
                    [desc appendString:ModelDescriptionAddIndent(ModelDescription(obj).mutableCopy, 1)];
                    [desc appendString:(i + 1 == max) ? @"\n" : @";\n"];
                }
                [desc appendString:@"]"];
                return desc;
            }
        }
        case JEREncodingTypeNSDictionary:
        case JEREncodingTypeNSMutableDictionary: {
            NSDictionary * dic = (id)model;
            NSMutableString * desc = [NSMutableString new];
            if (dic.count == 0) {
                return [desc stringByAppendingString:@"{}"];
            } else {
                NSArray * keys = dic.allKeys;
                [desc appendFormat:@"{\n"];
                for (NSUInteger i = 0, max = keys.count; i < max; i++) {
                    NSString * key = keys[i];
                    NSObject * value = dic[key];
                    [desc appendString:@"    "];
                    [desc appendFormat:@"%@ = %@", key, ModelDescriptionAddIndent(ModelDescription(value).mutableCopy, 1)];
                    [desc appendString:(i + 1 == max) ? @"\n" : @";\n"];
                }
                [desc appendFormat:@"}"];
            }
            return desc;
        }
        default: {
            NSMutableString * desc = [NSMutableString new];
            [desc appendFormat:@"<%@: %p>", model.class, model];
            if (modelMeta->_allPropertyMetas.count == 0) return desc;
            NSArray * properties = [modelMeta->_allPropertyMetas sortedArrayUsingComparator:^NSComparisonResult(_JERModelPropertyMeta * _Nonnull p1, _JERModelPropertyMeta * _Nonnull p2) {
                return [p1->_name compare:p2->_name];
            }];
            [desc appendFormat:@" {\n"];
            for (NSUInteger i = 0, max = properties.count; i < max; i++) {
                _YYModelPropertyMeta *property = properties[i];
                NSString *propertyDesc;
                if (property->_isCNumber) {
                    NSNumber *num = ModelCreateNumberFromProperty(model, property);
                    propertyDesc = num.stringValue;
                } else {
                    switch (property->_type & YYEncodingTypeMask) {
                        case YYEncodingTypeObject: {
                            id v = ((id (*)(id, SEL))(void *) objc_msgSend)((id)model, property->_getter);
                            propertyDesc = ModelDescription(v);
                            if (!propertyDesc) propertyDesc = @"<nil>";
                        } break;
                        case YYEncodingTypeClass: {
                            id v = ((id (*)(id, SEL))(void *) objc_msgSend)((id)model, property->_getter);
                            propertyDesc = ((NSObject *)v).description;
                            if (!propertyDesc) propertyDesc = @"<nil>";
                        } break;
                        case YYEncodingTypeSEL: {
                            SEL sel = ((SEL (*)(id, SEL))(void *) objc_msgSend)((id)model, property->_getter);
                            if (sel) propertyDesc = NSStringFromSelector(sel);
                            else propertyDesc = @"<NULL>";
                        } break;
                        case YYEncodingTypeBlock: {
                            id block = ((id (*)(id, SEL))(void *) objc_msgSend)((id)model, property->_getter);
                            propertyDesc = block ? ((NSObject *)block).description : @"<nil>";
                        } break;
                        case YYEncodingTypeCArray: case YYEncodingTypeCString: case YYEncodingTypePointer: {
                            void *pointer = ((void* (*)(id, SEL))(void *) objc_msgSend)((id)model, property->_getter);
                            propertyDesc = [NSString stringWithFormat:@"%p",pointer];
                        } break;
                        case YYEncodingTypeStruct: case YYEncodingTypeUnion: {
                            NSValue *value = [model valueForKey:property->_name];
                            propertyDesc = value ? value.description : @"{unknown}";
                        } break;
                        default: propertyDesc = @"<unknown>";
                    }
                }
                propertyDesc = ModelDescriptionAddIndent(propertyDesc.mutableCopy, 1);
                [desc appendFormat:@"    %@ = %@",property->_name, propertyDesc];
                [desc appendString:(i + 1 == max) ? @"\n" : @";\n"];
            }
            return desc;
        }
    }
}

@implementation NSObject (JERModel)

+ (NSDictionary *)_jer_dictionaryWithJSON:(id)json {
    if (!json || json == (id)kCFNull) return nil;
    NSDictionary * dic = nil;
    NSData * jsonData = nil;
    if ([json isKindOfClass:[NSDictionary class]]) {
        dic = json;
    } else if ([json isKindOfClass:[NSString class]]) {
        jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
    } else if ([json isKindOfClass:[NSData class]]) {
        jsonData = json;
    }
    if (jsonData) {
        dic = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:NULL];
        if (![dic isKindOfClass:[NSDictionary class]]) dic = nil;
    }
    return dic;
}

+ (nullable instancetype)modelWithJSON:(id)json {
    NSDictionary * dic = [self _jer_dictionaryWithJSON:json];
    return [self modelWithDictionary:dic];
}

+ (nullable instancetype)modelWithDictionary:(NSDictionary *)dictionary {
    if (!dictionary || dictionary == (id)kCFNull) return nil;
    if (![dictionary isKindOfClass:[NSDictionary class]]) return nil;
    
    Class cls = [self class];
    _JERModelMeta * modelMeta = [_JERModelMeta metaWithClass:cls];
    if (modelMeta->_hasCustomClassFromDictionary) {
        cls = [cls modelCustomClassForDictionary:dictionary] ?:cls;
    }
    
    NSObject * one = [cls new];
    if ([one modelSetWithDictionary:dictionary]) return one;
    return nil;
}

- (BOOL)modelSetWithJSON:(id)json {
    NSDictionary * dic = [NSObject _jer_dictionaryWithJSON:json];
    return [self modelSetWithDictionary:dic];
}

- (BOOL)modelSetWithDictionary:(NSDictionary *)dic {
    if (!dic || dic == (id)kCFNull) return NO;
    if (![dic isKindOfClass:[NSDictionary class]]) return NO;
    _JERModelMeta * modelMeta = [_JERModelMeta metaWithClass:object_getClass(self)];
    if (modelMeta->_keyMappedCount == 0) return NO;
    
    if (modelMeta->_hasCustomWillTransformDictionary) {
        dic = [((id<JERModel>)self) modelCustomWillTransformFromDictionary:dic];
        if (![dic isKindOfClass:[NSDictionary class]]) return NO;
    }
    
    ModelSetContext context = {0};
    context.modelMeta = (__bridge void *)modelMeta;
    context.model = (__bridge void *)self;
    context.dictionary = (__bridge void *)(dic);
    
    if (modelMeta->_keyMappedCount >= CFDictionaryGetCount((CFDictionaryRef)dic)) {
        CFDictionaryApplyFunction((CFDictionaryRef)dic, ModelSetWithDictionaryFunction, &context);
        if (modelMeta->_keyPathPropertyMetas) {
            CFArrayApplyFunction((CFArrayRef)modelMeta->_multiKeysPropertyMetas, CFRangeMake(0, CFArrayGetCount((CFArrayRef)modelMeta->_keyPathPropertyMetas)), ModelSetWithPropertyMetaArrayFunction, &context);
        }
        if (modelMeta->_multiKeysPropertyMetas) {
            CFArrayApplyFunction((CFArrayRef)modelMeta->_multiKeysPropertyMetas, CFRangeMake(0, CFArrayGetCount((CFArrayRef)modelMeta->_multiKeysPropertyMetas)), ModelSetWithPropertyMetaArrayFunction, &context);
        }
    } else {
        CFArrayApplyFunction((CFArrayRef)modelMeta->_allPropertyMetas, CFRangeMake(0, CFArrayGetCount((CFArrayRef)modelMeta->_allPropertyMetas)), ModelSetWithPropertyMetaArrayFunction, &context);
    }
    if (modelMeta->_hasCustomTransformFromDictionary) {
        return [((id<JERModel>)self) modelCustomTranformFromDictionary:dic];
    }
    return YES;
}

@end
