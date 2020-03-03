//
//  UITextField+JER_Custom.m
//  Test
//
//  Created by super on 2018/11/20.
//  Copyright © 2018 Jeremy. All rights reserved.
//

#import "UITextField+JER_Custom.h"

@implementation UITextField (JER_Custom)

- (void)selectAllText {
    UITextRange * range = [self textRangeFromPosition:self.beginningOfDocument toPosition:self.endOfDocument];
    [self setSelectedTextRange:range];
}

- (void)setSelectedRange:(NSRange)range {
    UITextPosition * beginning = self.beginningOfDocument;
    UITextPosition * start = [self positionFromPosition:beginning offset:range.location];
    UITextPosition * end = [self positionFromPosition:beginning offset:NSMaxRange(range)];
    UITextRange * selectionRange = [self textRangeFromPosition:start toPosition:end];
    [self setSelectedTextRange:selectionRange];
}

@end
