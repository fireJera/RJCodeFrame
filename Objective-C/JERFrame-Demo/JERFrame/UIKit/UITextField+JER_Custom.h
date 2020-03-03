//
//  UITextField+JER_Custom.h
//  Test
//
//  Created by super on 2018/11/20.
//  Copyright © 2018 Jeremy. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITextField (JER_Custom)

- (void)selectAllText;

- (void)setSelectedRange:(NSRange)range;

@end

NS_ASSUME_NONNULL_END
