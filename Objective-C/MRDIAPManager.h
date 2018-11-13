//
//  MRDIAPManager.h
//  UncleCon
//
//  Created by Jeremy on 10/02/2018.
//  Copyright © 2018 Jeremy. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IAPManagerDelegate <NSObject>

- (void)IAPFailedWithWrongInfor:(NSString *)informationStr;

- (void)IAPPaySuccessFunctionWithBase64:(NSString *)base64Str;

@end

extern NSString * MRDIAPCancelString;

@interface MRDIAPManager : NSObject

@property(nonatomic ,weak) id<IAPManagerDelegate> IAPDelegate;

@property (nonatomic, copy) NSString * orderId;

+ (instancetype)sharedManager;

- (void)getProductInfo:(NSString *)productIdentifier orderId:(NSString *)orderId;

- (void)checktAllFailOrder;

@end
