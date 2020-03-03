//
//  Example.h
//  JERFrame
//
//  Created by super on 2018/11/30.
//  Copyright © 2018 Jeremy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Father : NSObject

@property (nonatomic, copy) NSString * name;
@property (nonatomic, copy) NSArray<Son *> * kids;

@end

@implementation Father

+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper {
    return @{@"age"  : @"real_age", //@"real.age"
             @"desc"  : @"ext.desc",
             @"name": @[@"nickname", @"name", @"engName"]};
}

+ (nullable NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass {
    return @{@"kids" : [Son class],
             @"kids" : Son.class,
             @"kids" : @"Son" };
}

  @{"result":
        {@"data":
            {  @"name":@"name",
                @"kids":@[ {@"name":@"son", @"age":5} ]
            }
        }
    }

+ (nullable Class)modelCustomClassForDictionary:(NSDictionary *)dictionary {
    if (dictionary[@"data"] != nil) {
        return [Father class];
    } else if (dictionary[@"kids"] != nil) {
        return [Son class];
    }
}

+ (nullable NSArray<NSString *> *)modelPropertyBlacklist {
    return @[@"name"];
}

+ (nullable NSArray<NSString *> *)modelPropertyWhitelist {
    return @[@"name"];
}

- (NSDictionary *)modelCustomWillTransformFromDictionary:(NSDictionary *)dic {
    
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    
}

- (BOOL)modelCustomTransformToDictionary:(NSMutableDictionary *)dic {
    
}

@end

@interface Son : NSObject

@property (nonatomic, copy) NSString * name;
@property (nonatomic, assign) NSUInteger age;

@end


nameIvar = {
    _ivar = ivar;
    _name = name;
    offset = _name_offset;
    typeEncoding = T@"NSString",C,N,V_name;
    type = YYEncodingTypeObject;
}

kidsIvar = {
    _ivar = ivar;
    _kids = kids;
    offset = _kids_offset;
    typeEncoding = T@"NSArray",C,N,V_kids;
    type = YYEncodingTypeObject;
}


nameIvar = {
    _ivar = ivar;
    _name = name;
    offset = _name_offset;
    typeEncoding = T@"NSString",V_name;
    "nonatomic copy NSString";
    type = YYEncodingTypeObject | YYEncodingTypeQualifierIn;
}

ageIvar = {
    _ivar = ivar;
    _name = age;
    offset = _age_offset;
    typeEncoding = T@"NSUInteger",N,V_age;
    type = YYEncodingTypeUInt64 | YYEncodingTypeQualifierIn;
}

(YYClassPropertyInfo)nameProperty = {
    _property = (objc_property_t)nameProperty;
    _name = name;
    //type 从typeEncoding中解析出来的
    _type = YYEncodingTypePropertyNonatomic | YYEncodingTypePropertyCopy | YYEncodingTypeObject;
    _typeEncoding = t@"NSString", C, N, V_name;
    _ivarName = _name;                  //从typeEncoding中解析出来的
    cls = NSString;                     //从typeEncoding中解析出来的
    _protocols = NSArray * protocols    //也是从typeEncoding中解析出来的
    _getter =  // 分自定义或者编译器自动实现
    _settet =  // 分自定义或者编译器自动实现
}

nameSetterMethodInfo = {
    _method = setterMethod;
    _sel = setterSel;
    _imp = setImp;
    _name = setName:;
    _typeEncoding = v20@0:8
    _returnTypeEncoding = v;
    _argumentTypeEncodings = @[
                               T@"NSUInteger",v_name;
                               ];
}

nameGetterMethodInfo = {
    _method = getterMethod;
    _sel = getterSel;
    _imp = getImp;
    _name = getName:;
    _typeEncoding = v20@0:8
    _returnTypeEncoding = i;
    _argumentTypeEncodings = nil;
}

//[typeEncoding](https://www.jianshu.com/p/f4129b5194c0)

SonClassInfo = {
    _cls = Son;
    _superCls = NSObject;
    _isMeta = isMeta;
    _metaCls = SonMetaCls;
    _name = Son;
    _superClassInfo = (YYClassInfo *)NSObjectClassInfo;
    _methodInfos = @{
                     @"setName:": nameSetterMethodInfo,
                     @"name": nameGetterMethodInfo,
                     @"setAge:":@"",
                     @"age":@""
                     };
    
    _ivarInfos = @{
                   @"_name": nameIvar;
                   @"_age": ageIvar;
                   }
    _propertyInfo = @{
                      @"name": nameProperty;
                      @"age": agePrperty;
                      }
}


(_YYModelPropertyMeta *)name : {
    _name = name;
    _type = (nameProperty.type)YYEncodingTypePropertyNonatomic | YYEncodingTypePropertyCopy | YYEncodingTypeObject;
    _info = nameProperty;
    _genericCls = nil;      //如果实现了就有 Son
    _nsType = YYEncodingTypeNSString //根据nameProperty.cls得出;和_isCNumber不共存
//    _isCNumber = YYEncodingTypeUInt64 //根据_type得出;和_nsType不共存
    //if YYEncodingTypeStruct if nameProperty.typeEncoding contain struct
    // _isStructAvailableForKeyedArchiver = yes;
    _cls =  NSString;//nameProperty.cls
    _hasCustomClassFromDictionary = YES;
    _getter = nameProperty.getter;
    _setter = nameProperty.setter;
    _isKVCCompatible = YES;
    _mappedToKey = @"nickname";
    _mappedToKeyPath = nil //如果有@[@"dic.nickname", @"nickname"]; = @[@"dic", @"nickname"]
    _mappedToKeyArray = @[@"nickname", @"name", @"engname"];
}

(_YYModelPropertyMeta *)age : {
    _name = age;
    _type = (ageProperty.type)YYEncodingTypePropertyNonatomic | YYEncodingTypeUInt64;
    _info = ageProperty;
    _genericCls = nil;      //如果实现了就有 Son
//    _nsType = YYEncodingTypeNSString //根据nameProperty.cls得出;和_isCNumber不共存
    _isCNumber = YYEncodingTypeUInt64 //根据_type得出;和_nsType不共存
    //if YYEncodingTypeStruct if nameProperty.typeEncoding contain struct
    // _isStructAvailableForKeyedArchiver = yes;
//    _cls =  NSString;//nameProperty.cls
    _hasCustomClassFromDictionary = YES;
    _getter = nameProperty.getter;
    _setter = nameProperty.setter;
    _isKVCCompatible = YES;
    _mappedToKey = @"real_age";
//    _mappedToKeyPath = @[@"real", @"age"];
    _next = nil;
    _mappedToKeyArray = nil;
}

(_YYModelMeta *)Father : {
    _classInfo = FatherClassInfo;
    _allPropertyMetas = @[namePropertyMeta, agePropertyMeta];
    _mapper = @{@"name": @[@"",@""]
                @"age" : @"real_age",
                @"some": @"some",
                }
    _keyPathPropertyMetas = @[namePropertyMeta, agePropertyMeta];
    _multiKeysPropertyMetas = @[namePropertyMeta];
    _keyMappedCount = 3 //有多少个property就是几
    _nsType = YYEncodingTypeUnknow;
    _hasCustomWillTransformFromDictionary = YES;
    _hasCustomTransformFromDictionary = YES;
    _hasCustomTransformToDictionary = YES;
    _hasCustomClassFromDictionary = YES;
}
