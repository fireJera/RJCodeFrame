//
//  NSDate+JER_Custom.h
//  JERFrame
//
//  Created by super on 2018/11/21.
//  Copyright © 2018 Jeremy. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (JER_Custom)

@property (nonatomic, readonly) NSInteger year;
@property (nonatomic, readonly) NSInteger month;
@property (nonatomic, readonly) NSInteger day;
@property (nonatomic, readonly) NSInteger hour;
@property (nonatomic, readonly) NSInteger minute;
@property (nonatomic, readonly) NSInteger second;
@property (nonatomic, readonly) NSInteger nanosecond;
@property (nonatomic, readonly) NSInteger weekday;
@property (nonatomic, readonly) NSInteger weekdayOrdinal;
@property (nonatomic, readonly) NSInteger weekOfMonth;
@property (nonatomic, readonly) NSInteger weekOfYear;
@property (nonatomic, readonly) NSInteger yearForWeekOfYear;
@property (nonatomic, readonly) NSInteger quarter;
@property (nonatomic, readonly) BOOL isLeapMonth;
@property (nonatomic, readonly) BOOL isLeapYear;
@property (nonatomic, readonly) BOOL isToday;
@property (nonatomic, readonly) BOOL isYesterday;

- (nullable NSDate *)dateByAddingYears:(NSInteger)years;

- (nullable NSDate *)dateByAddingMonths:(NSInteger)months;

- (nullable NSDate *)dateByAddingHours:(NSInteger)hours;

- (nullable NSDate *)dateByAddingDays:(NSInteger)days;

- (nullable NSDate *)dateByAddingMinutes:(NSInteger)minutes;

- (nullable NSDate *)dateByAddingSeconds:(NSInteger)seconds;

@end

NS_ASSUME_NONNULL_END
