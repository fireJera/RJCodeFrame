//
//  UITableView+JER_Custom.h
//  Test
//
//  Created by super on 2018/11/20.
//  Copyright © 2018 Jeremy. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITableView (JER_Custom)

- (void)updateWithBlock:(void(^)(UITableView  * tableView))block;

- (void)scrollToRow:(NSUInteger)row inSection:(NSUInteger)section atScrollPosition:(UITableViewScrollPosition)position withRowAnimation:(UITableViewRowAnimation)animation;

- (void)insertRow:(NSUInteger)row inSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation;

- (void)reloadRow:(NSUInteger)row inSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation;

- (void)deleteRow:(NSUInteger)row inSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation;

- (void)insertRowAtIndexPath:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)animaion;

- (void)reloadRowAtIndexPath:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)animation;

- (void)deleteRowAtIndexPath:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)animation;

- (void)insertSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation;

- (void)deleteSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation;

- (void)reloadSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation;

- (void)clearSelectedRowAnimated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
