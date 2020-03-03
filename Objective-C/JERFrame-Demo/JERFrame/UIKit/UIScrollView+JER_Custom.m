//
//  UIScrollView+MRD_Custom.m
//  Test
//
//  Created by super on 2018/11/20.
//  Copyright © 2018 Jeremy. All rights reserved.
//

#import "UIScrollView+JER_Custom.h"

@implementation UIScrollView (JER_Custom)

- (void)scrollToTop {
    [self scrollToTopAnimated:YES];
}

- (void)scrollToBottom {
    [self scrollToBottomAnimated:YES];
}

- (void)scrollToLeft {
    [self scrollToLeftAnimated:YES];
}

- (void)scrollToRight {
    [self scrollToRightAnimated:YES];
}

- (void)scrollToTopAnimated:(BOOL)animated {
    CGPoint offset = self.contentOffset;
    offset.y = 0 - self.contentInset.top;
    [self setContentOffset:offset animated:animated];
}

- (void)scrollToBottomAnimated:(BOOL)animated {
    CGPoint offset = self.contentOffset;
    offset.y = self.contentSize.height - self.bounds.size.height + self.contentInset.bottom;
    [self setContentOffset:offset animated:animated];
}

- (void)scrollToLeftAnimated:(BOOL)animated {
    CGPoint offset = self.contentOffset;
    offset.x = 0 - self.contentInset.left;
    [self setContentOffset:offset animated:animated];
}

- (void)scrollToRightAnimated:(BOOL)animated {
    CGPoint offset = self.contentOffset;
    offset.x = self.contentSize.width - self.bounds.size.width + self.contentInset.right;
    [self setContentOffset:offset animated:animated];
}
@end
