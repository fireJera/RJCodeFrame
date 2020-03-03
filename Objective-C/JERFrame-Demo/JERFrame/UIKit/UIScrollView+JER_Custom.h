//
//  UIScrollView+MRD_Custom.h
//  Test
//
//  Created by super on 2018/11/20.
//  Copyright © 2018 Jeremy. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIScrollView (JER_Custom)

- (void)scrollToTop;
- (void)scrollToBottom;
- (void)scrollToLeft;
- (void)scrollToRight;

- (void)scrollToTopAnimated:(BOOL)animated;
- (void)scrollToBottomAnimated:(BOOL)animated;
- (void)scrollToLeftAnimated:(BOOL)animated;
- (void)scrollToRightAnimated:(BOOL)animated;
@end

NS_ASSUME_NONNULL_END
