//
//  NSThread+JER_Custom.h
//  JERFrame
//
//  Created by super on 2018/11/22.
//  Copyright © 2018 Jeremy. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSThread (JER_Custom)

+ (void)addAutoreleasePoolToCurrentRunloop;

@end

NS_ASSUME_NONNULL_END
