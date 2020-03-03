//
//  JERClassInfo.h
//  JERFrame
//
//  Created by super on 2018/11/22.
//  Copyright © 2018 Jeremy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, JEREncodingType) {
    JEREncodingTypeMask         = 0xFF,
    JEREncodingTypeUnknow       = 0,
    JEREncodingTypeVoid         = 1,
    JEREncodingTypeBool         = 2,
    JEREncodingTypeInt8         = 3,    ///< char BOOL
    JEREncodingTypeUInt8        = 4,    ///< unsigned char
    JEREncodingTypeInt16        = 5,    ///< short
    JEREncodingTypeUInt16       = 6,    ///< unsigned short
    JEREncodingTypeInt32        = 7,    ///< int
    JEREncodingTypeUInt32       = 8,    ///< unsigned int
    JEREncodingTypeInt64        = 9,    ///< long long
    JEREncodingTypeUInt64       = 10,   ///< unsigned long long
    JEREncodingTypeFloat        = 11,
    JEREncodingTypeDouble       = 12,
    JEREncodingTypeLongDouble   = 13,
    JEREncodingTypeObject       = 14,
    JEREncodingTypeClass        = 15,
    JEREncodingTypeSEL          = 16,
    JEREncodingTypeBlock        = 17,
    JEREncodingTypePointer      = 18,
    JEREncodingTypeStruct       = 19,
    JEREncodingTypeUnion        = 20,
    JEREncodingTypeCString      = 21,
    JEREncodingTypeCArray       = 22,
    
    JEREncodingTypeQualifierMask    = 0xFF00,
    JEREncodingTypeQualifierConst   = 1 << 8,
    JEREncodingTypeQualifierIn      = 1 << 9,
    JEREncodingTypeQualifierInout   = 1 << 10,
    JEREncodingTypeQualifierOut     = 1 << 11,
    JEREncodingTypeQualifierBycopy  = 1 << 12,
    JEREncodingTypeQualifierByref   = 1 << 13,
    JEREncodingTypeQualifierOneway  = 1 << 14,
    
    JEREncodingTypePropertyMask         = 0xFF0000,
    JEREncodingTypePropertyReadOnly     = 1 << 16,
    JEREncodingTypePropertyCopy         = 1 << 17,
    JEREncodingTypePropertyRetain       = 1 << 18,
    JEREncodingTypePropertyNonatomic    = 1 << 19,
    JEREncodingTypePropertyWeak         = 1 << 20,
    JEREncodingTypePropertyCustomGetter = 1 << 21,
    JEREncodingTypePropertyCustomSetter = 1 << 22,
    JEREncodingTypePropertyDynamic      = 1 << 23,
};

JEREncodingType JEREncodingGetType(const char * typeEncoding);

@interface JERClassIvarInfo : NSObject

@property (nonatomic, assign, readonly) Ivar ivar;
@property (nonatomic, strong, readonly) NSString * name;
@property (nonatomic, assign, readonly) ptrdiff_t offset;
@property (nonatomic, strong, readonly) NSString * typeEncoding;
@property (nonatomic, assign, readonly) JEREncodingType type;

- (instancetype)initWithIvar:(Ivar)ivar;

@end

@interface JERClassMethodInfo : NSObject

@property (nonatomic, assign, readonly) Method method;
@property (nonatomic, strong, readonly) NSString * name;
@property (nonatomic, assign, readonly) SEL sel;
@property (nonatomic, assign, readonly) IMP imp;
@property (nonatomic, strong, readonly) NSString * typeEncoding;

@property (nonatomic, strong, readonly) NSString * returnTypeEncoding;
@property (nonatomic, strong, readonly) NSArray<NSString *> * argumentsTypeEncodings;

- (instancetype)initWithMethod:(Method)method;

@end

@interface JERClassPropertyInfo : NSObject

@property (nonatomic, assign, readonly) objc_property_t property;
@property (nonatomic, strong, readonly) NSString * name;
@property (nonatomic, assign, readonly) JEREncodingType type;
@property (nonatomic, strong, readonly) NSString * typeEncoding;
@property (nonatomic, strong, readonly) NSString * ivarName;
@property (nullable, nonatomic, assign, readonly) Class cls;
@property (nullable, nonatomic, strong, readonly) NSArray<NSString *> * protocols;
@property (nonatomic, assign, readonly) SEL setter;
@property (nonatomic, assign, readonly) SEL getter;

- (instancetype)initWithProperty:(objc_property_t)property;

@end

@interface JERClassInfo : NSObject

@property (nonatomic, assign, readonly) Class cls;
@property (nullable, nonatomic, assign, readonly) Class superCls;
@property (nullable, nonatomic, assign, readonly) Class metaCls;
@property (nonatomic, assign, readonly) BOOL isMeta;
@property (nonatomic, strong, readonly) NSString * name;
@property (nonatomic, strong, readonly) JERClassInfo * superClsInfo;

@property (nonatomic, strong, readonly) NSDictionary<NSString *, JERClassIvarInfo *> * ivarInfos;
@property (nonatomic, strong, readonly) NSDictionary<NSString *, JERClassMethodInfo *> * methodInfos;
@property (nonatomic, strong, readonly) NSDictionary<NSString *, JERClassPropertyInfo *> * propertyInfos;

- (void)setNeedUpdate;

- (BOOL)needUpdate;

+ (nullable instancetype)classInfoWithClass:(Class)cls;

+ (nullable instancetype)classInfoWithClassName:(NSString *)className;

@end

NS_ASSUME_NONNULL_END
