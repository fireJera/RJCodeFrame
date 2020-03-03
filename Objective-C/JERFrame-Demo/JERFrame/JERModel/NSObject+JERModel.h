//
//  NSObject+JERModel.h
//  JERFrame
//
//  Created by super on 2018/11/21.
//  Copyright © 2018 Jeremy. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (JERModel)

+ (nullable instancetype)modelWithJSON:(id)json;

+ (nullable instancetype)modelWithDictionary:(NSDictionary *)dictionary;

- (BOOL)modelSetWithJSON:(id)json;

- (BOOL)modelSetWithDictionary:(NSDictionary *)dic;

- (nullable id)modelToJSONObject;

- (nullable NSData *)modelToJSONData;

- (nullable NSString *)modelToJSONString;

- (nullable id)modelCopy;

- (void)modelEncodeWithCoder:(NSCoder *)aCoder;

- (id)modelInitWithCoder:(NSCoder *)aDecoder;

- (NSUInteger)modelHash;

- (BOOL)modelIsEqual:(id)model;

- (NSString *)modelDescription;

@end

@protocol JERModel <NSObject>
@optional

+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper;

+ (nullable NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass;

+ (nullable Class)modelCustomClassForDictionary:(NSDictionary *)dictionary;

+ (nullable NSArray<NSString *> *)modelPropertyBlacklist;

+ (nullable NSArray<NSString *> *)modelPropertyWhitelist;

- (NSDictionary *)modelCustomWillTransformFromDictionary:(NSDictionary *)dic;

- (BOOL)modelCustomTranformFromDictionary:(NSDictionary *)dic;

- (BOOL)modelCustomTranformToDictionary:(NSDictionary *)dic;

@end


NS_ASSUME_NONNULL_END
