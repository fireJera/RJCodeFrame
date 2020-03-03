//
//  JERClassInfo.m
//  JERFrame
//
//  Created by super on 2018/11/22.
//  Copyright © 2018 Jeremy. All rights reserved.
//

#import "JERClassInfo.h"

JEREncodingType JEREncodingGetType(const char * typeEncoding) {
    char * type = (char *)typeEncoding;
    if (!type) return JEREncodingTypeUnknow;
    size_t len = strlen(type);
    if (len == 0) return JEREncodingTypeUnknow;
    JEREncodingType qualifier = 0;
    bool prefix = true;
    while (prefix) {
        switch (*type) {
            case 'r':
                qualifier |= JEREncodingTypeQualifierConst;
                type++;
                break;
            case 'n':
                qualifier |= JEREncodingTypeQualifierIn;
                type++;
                break;
            case 'N':
                qualifier |= JEREncodingTypeQualifierInout;
                type++;
                break;
            case 'o':
                qualifier |= JEREncodingTypeQualifierOut;
                type++;
                break;
            case 'O':
                qualifier |= JEREncodingTypeQualifierBycopy;
                type++;
                break;
            case 'R':
                qualifier |= JEREncodingTypeQualifierByref;
                type++;
                break;
            case 'V':
                qualifier |= JEREncodingTypeQualifierOneway;
                type++;
                break;
            default:
                prefix = false;
                break;
        }
    }
    len = strlen(type);
    if (len == 0) return JEREncodingTypeUnknow | qualifier;
    
    switch (*type) {//        case 'b': return qualifier |= JEREncodingTypeN;
        case 'c': return qualifier |= JEREncodingTypeInt8;
        case 'i': return qualifier |= JEREncodingTypeInt32;
        case 's': return qualifier |= JEREncodingTypeInt16;
        case 'l': return qualifier |= JEREncodingTypeInt32;
        case 'q': return qualifier |= JEREncodingTypeInt64;
        case 'C': return qualifier |= JEREncodingTypeUInt8;
        case 'I': return qualifier |= JEREncodingTypeUInt32;
        case 'S': return qualifier |= JEREncodingTypeUInt16;
        case 'L': return qualifier |= JEREncodingTypeUInt32;
        case 'Q': return qualifier |= JEREncodingTypeUInt64;
        case 'f': return qualifier |= JEREncodingTypeFloat;
        case 'd': return qualifier |= JEREncodingTypeDouble;
        case 'D': return qualifier |= JEREncodingTypeLongDouble;
        case 'B': return qualifier |= JEREncodingTypeBool;
        case 'v': return qualifier |= JEREncodingTypeVoid;
        case '*': return qualifier |= JEREncodingTypeCString;
        case '#': return qualifier |= JEREncodingTypeClass;
        case ':': return qualifier |= JEREncodingTypeSEL;
        case '[': return qualifier |= JEREncodingTypeCArray;
        case '{': return qualifier |= JEREncodingTypeStruct;
        case '(': return qualifier |= JEREncodingTypeUnion;
        case '^': return qualifier |= JEREncodingTypePointer;
//        case '?': return qualifier |= JEREncodingTypeUnknow;
        case '@':{
            if (len == 2 && *(type + 1) == '?')
                return qualifier |= JEREncodingTypeBlock;
            else
                return qualifier |= JEREncodingTypeObject;
        }
        default: return qualifier |= JEREncodingTypeUnknow;
    }
    
    return qualifier;
}

@implementation JERClassIvarInfo

- (instancetype)initWithIvar:(Ivar)ivar {
    if (!ivar) return nil;
    if (self = [super init]) {
        _ivar = ivar;
        const char * name = ivar_getName(ivar);
        if (name) {
            _name = [NSString stringWithUTF8String:name];
        }
        _offset = ivar_getOffset(ivar);
        const char * typeEncoding = ivar_getTypeEncoding(ivar);
        if (typeEncoding){
            _typeEncoding = [NSString stringWithUTF8String:typeEncoding];
            _type = JEREncodingGetType(typeEncoding);
        }
    }
    return self;
}

@end

@implementation JERClassMethodInfo

- (instancetype)initWithMethod:(Method)method {
    if (!method) return nil;
    if (self = [super init]) {
        _method = method;
        _sel = method_getName(method);
        _imp = method_getImplementation(method);
        const char * name = sel_getName(_sel);
        if (name) {
            _name = [NSString stringWithUTF8String:name];
        }
        const char * typeEncoding = method_getTypeEncoding(method);
        if (typeEncoding) {
            _typeEncoding = [NSString stringWithUTF8String:typeEncoding];
        }
        char * returnTypeEncoding = method_copyReturnType(method);
        if (returnTypeEncoding) {
            _returnTypeEncoding = [NSString stringWithUTF8String:returnTypeEncoding];
        }
        unsigned int num = method_getNumberOfArguments(method);
        if (num > 0) {
            NSMutableArray * arguments = [NSMutableArray array];
            for (unsigned int i = 0; i < num; i++) {
                char * argument = method_copyArgumentType(method, i);
                NSString * type = argument ? [NSString stringWithUTF8String:argument] : nil;
                [arguments addObject:type ? type : @""];
                if (argument) free(argument);
            }
            _argumentsTypeEncodings = [arguments copy];
        }
    }
    return self;
}

@end

@implementation JERClassPropertyInfo

- (instancetype)initWithProperty:(objc_property_t)property {
    if (!property) return nil;
    if (self = [super init]) {
        _property = property;
        const char * name = property_getName(property);
        if (name) {
            _name = [NSString stringWithUTF8String:name];
        }
        
        JEREncodingType type = 0;
        unsigned int attrCount = 0;
        objc_property_attribute_t * attrs = property_copyAttributeList(property, &attrCount);
        for (unsigned int i = 0; i < attrCount; i++) {
            switch (attrs[i].name[0]) {
                case 'T': {
                    if (attrs[i].value) {
                        _typeEncoding = [NSString stringWithUTF8String:attrs[i].value];
                        type = JEREncodingGetType(attrs[i].value);
                        if ((type & JEREncodingTypeMask) == JEREncodingTypeObject && _typeEncoding.length) {
                            NSScanner * scanner = [NSScanner scannerWithString:_typeEncoding];
                            if (![scanner scanString:@"@\"" intoString:NULL]) continue;
                            
                            NSString * clsName = nil;
                            if ([scanner scanUpToCharactersFromSet: [NSCharacterSet characterSetWithCharactersInString:@"\"<"] intoString:&clsName]) {
                                if (clsName.length) _cls = objc_getClass(clsName.UTF8String);
                            }
                            NSMutableArray * protocols = nil;
                            while ([scanner scanString:@"<" intoString:NULL]) {
                                NSString *protocol = nil;
                                if ([scanner scanUpToString:@">" intoString:&protocol]) {
                                    if (protocol.length) {
                                        if (!protocol) protocols = [NSMutableArray new];
                                        [protocols addObject:protocol];
                                    }
                                }
                                [scanner scanUpToString:@">" intoString:NULL];
                            }
                            _protocols = protocols;
                        }
                    }
                }
                    break;
                case 'V':
                    if (attrs[i].value) {
                        _ivarName = [NSString stringWithUTF8String:attrs[i].value];
                    }
                    break;
                case 'R':
                    type |= JEREncodingTypePropertyReadOnly;
                    break;
                case 'C':
                    type |= JEREncodingTypePropertyCopy;
                    break;
                case '&':
                    type |= JEREncodingTypePropertyRetain;
                    break;
                case 'N':
                    type |= JEREncodingTypePropertyNonatomic;
                    break;
                case 'G': {
                    type |= JEREncodingTypePropertyCustomGetter;
                    if (attrs[i].value) {
                        _getter = NSSelectorFromString([NSString stringWithUTF8String:attrs[i].value]);
                    }
                }
                    break;
                case 'S': {
                    type |= JEREncodingTypePropertyCustomSetter;
                    if (attrs[i].value) {
                        _setter = NSSelectorFromString([NSString stringWithUTF8String:attrs[i].value]);
                    }
                }
                    break;
                case 'D':
                    type |= JEREncodingTypePropertyDynamic;
                    break;
                case 'W':
                    type |= JEREncodingTypePropertyWeak;
                    break;
//                case 'P':
//                    type |= JEREncodingTypeProperty;
//                    break;
                case 't':
                    break;
                default:
                    break;
            }
        }
        
        if (attrs) {
            free(attrs);
            attrs = NULL;
        }
        
        _type = type;
        if (_name.length) {
            if (!_getter) {
                _getter = _getter = NSSelectorFromString(_name);
            }
            if (!_setter) {
                _setter = NSSelectorFromString([NSString stringWithFormat:@"set%@", [_name capitalizedString]]);
            }
        }
    }
    return self;
}

@end

@implementation JERClassInfo {
    BOOL _needUpdate;
}

- (instancetype)initWithClass:(Class)cls {
    if (!cls) return nil;
    if (self = [super init]) {
        _cls = cls;
        _superCls = class_getSuperclass(cls);
        _superClsInfo = [JERClassInfo classInfoWithClass:_superCls];
        _isMeta = class_isMetaClass(cls);
        if (!_isMeta) {
            _metaCls = objc_getMetaClass(class_getName(cls));
        }
        _name = NSStringFromClass(cls);
        
        [self _update];
    }
    return self;
}

- (void)_update {
    _ivarInfos = nil;
    _methodInfos = nil;
    _propertyInfos = nil;
    
    Class cls = self.cls;
    
    unsigned int ivarCount = 0;
    
    Ivar * ivars = class_copyIvarList(cls, &ivarCount);
    NSMutableDictionary * dic = [NSMutableDictionary dictionary];
    if (ivars) {
        for (int i = 0; i < ivarCount; i++) {
            Ivar ivar = ivars[i];
            JERClassIvarInfo * ivarInfo = [[JERClassIvarInfo alloc] initWithIvar:ivar];
            [dic setObject:ivarInfo forKey:ivarInfo.name];
        }
        _ivarInfos = [dic copy];
    }
    
    unsigned int propertyCount = 0;
    objc_property_t * propertys = class_copyPropertyList(cls, &propertyCount);
    if (propertys) {
        [dic removeAllObjects];
        for (int i = 0; i < propertyCount; i++) {
            objc_property_t property = propertys[i];
            JERClassPropertyInfo * propertyInfo = [[JERClassPropertyInfo alloc] initWithProperty:property];
            [dic setObject:propertyInfo forKey:propertyInfo.name];
        }
        _propertyInfos = [dic copy];
    }
    
    unsigned int methodCount = 0;
    Method * methods = class_copyMethodList(cls, &methodCount);
    if (methods) {
        [dic removeAllObjects];
        for (int i = 0; i < methodCount; i++) {
            Method method = methods[i];
            JERClassMethodInfo * methodInfo = [[JERClassMethodInfo alloc] initWithMethod:method];
            [dic setObject:methodInfo forKey:methodInfo.name];
        }
        _methodInfos = [dic copy];
    }
    [dic removeAllObjects];
    
    if (!_ivarInfos) _ivarInfos = @{};
    if (!_propertyInfos) _propertyInfos = @{};
    if (!_methodInfos) _methodInfos = @{};
    
    _needUpdate = NO;
}

- (void)setNeedUpdate {
    _needUpdate = YES;
}

- (BOOL)needUpdate {
    return _needUpdate;
}

+ (instancetype)classInfoWithClass:(Class)cls {
    if (!cls) return nil;
    static CFMutableDictionaryRef classCache;
    static CFMutableDictionaryRef metaCache;
    static dispatch_once_t onceToken;
    static dispatch_semaphore_t lock;
    dispatch_once(&onceToken, ^{
        classCache = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        metaCache = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        lock = dispatch_semaphore_create(1);
    });
    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
    JERClassInfo * classInfo = CFDictionaryGetValue(class_isMetaClass(cls) ? metaCache : classCache, (__bridge const void *)(cls));
    if (classInfo && classInfo->_needUpdate) {
        [classInfo _update];
    }
    dispatch_semaphore_signal(lock);
    if (!classInfo) {
        classInfo = [[JERClassInfo alloc] initWithClass:cls];
        if (classInfo) {
            dispatch_semaphore_wait(lock, 1);
            CFDictionarySetValue(classInfo.isMeta ? metaCache : classCache, (__bridge const void *)(cls) , (__bridge const void *)(classInfo));
            dispatch_semaphore_signal(lock);
        }
    }
    return classInfo;
}

+ (instancetype)classInfoWithClassName:(NSString *)className {
    Class cls = NSClassFromString(className);
    return [self classInfoWithClass:cls];
}

@end
