
//
//  UITableView+JER_Custom.m
//  Test
//
//  Created by super on 2018/11/20.
//  Copyright © 2018 Jeremy. All rights reserved.
//

#import "UITableView+JER_Custom.h"

@implementation UITableView (JER_Custom)

- (void)updateWithBlock:(void (^)(UITableView * _Nonnull))block {
    if (@available(ios 11.0, *)) {
        [self performBatchUpdates:^{
            if (block) block(self);
        } completion:nil];
    } else {
        [self beginUpdates];
        if (block) block(self);
        [self endUpdates];
    }
}

- (void)scrollToRow:(NSUInteger)row inSection:(NSUInteger)section atScrollPosition:(UITableViewScrollPosition)position withRowAnimation:(UITableViewRowAnimation)animation {
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:row inSection:section];
    [self scrollToRowAtIndexPath:indexPath atScrollPosition:position animated:animation];
}

- (void)insertRow:(NSUInteger)row inSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation {
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:row inSection:section];
    [self insertRowAtIndexPath:indexPath withRowAnimation:animation];
}

- (void)reloadRow:(NSUInteger)row inSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation {
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:row inSection:section];
    [self reloadRowAtIndexPath:indexPath withRowAnimation:animation];
}

- (void)deleteRow:(NSUInteger)row inSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation {
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:row inSection:section];
    [self deleteRowAtIndexPath:indexPath withRowAnimation:animation];
}

- (void)insertRowAtIndexPath:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)animaion {
    if (!indexPath) return;
    [self insertRowsAtIndexPaths:@[indexPath] withRowAnimation:animaion];
}

- (void)reloadRowAtIndexPath:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)animation {
    if (!indexPath) return;
    [self reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:animation];
}

- (void)deleteRowAtIndexPath:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)animation {
    if (!indexPath) return;
    [self deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:animation];
}

- (void)insertSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation {
    [self insertSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:animation];
}

- (void)reloadSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation {
    [self reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:animation];
}

- (void)deleteSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation {
    [self deleteSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:animation];
}

- (void)clearSelectedRowAnimated:(BOOL)animated {
    NSArray<NSIndexPath *> * indexs = [self indexPathsForSelectedRows];
    [indexs enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self deselectRowAtIndexPath:obj animated:animated];
    }];
}

@end
