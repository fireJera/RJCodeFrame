//
//  UIImageView+UCN_Frame.h
//  UncleCon
//
//  Created by super on 03/11/2017.
//  Copyright © 2017 super. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (JER_Frame)

//这些不是真正的属性哦，不要误会
@property (nonatomic, assign) CGFloat left;
@property (nonatomic, assign) CGFloat right;
@property (nonatomic, assign) CGFloat top;
@property (nonatomic, assign) CGFloat bottom;
@property (nonatomic, assign) CGPoint origin;
@property (nonatomic, assign) CGPoint leftBottom;
@property (nonatomic, assign) CGPoint rightTop;
@property (nonatomic, assign) CGPoint rightBottom;
@property (nonatomic, assign) CGFloat centerX;
@property (nonatomic, assign) CGFloat centerY;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGSize size;

@end
