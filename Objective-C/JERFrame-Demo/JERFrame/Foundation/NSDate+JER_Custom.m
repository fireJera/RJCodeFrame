//
//  NSDate+JER_Custom.m
//  JERFrame
//
//  Created by super on 2018/11/21.
//  Copyright © 2018 Jeremy. All rights reserved.
//

#import "NSDate+JER_Custom.h"

@implementation NSDate (JER_Custom)

- (NSInteger)year {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:self] year];
}

- (NSInteger)month {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitMonth fromDate:self] month];
}

- (NSInteger)day {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitDay fromDate:self] day];
}

- (NSInteger)hour {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitHour fromDate:self] hour];
}

- (NSInteger)minute {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitMinute fromDate:self] minute];
}

- (NSInteger)second {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitSecond fromDate:self] second];
}

- (NSInteger)nanosecond {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitNanosecond fromDate:self] nanosecond];
}

- (NSInteger)weekday {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitWeekday fromDate:self] weekday];
}

- (NSInteger)weekdayOrdinal {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitWeekdayOrdinal fromDate:self] weekdayOrdinal];
}

- (NSInteger)weekOfMonth {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitWeekOfMonth fromDate:self] weekOfMonth];
}

- (NSInteger)weekOfYear {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitWeekOfYear fromDate:self] weekOfYear];
}

- (NSInteger)yearForWeekOfYear {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitYearForWeekOfYear fromDate:self] yearForWeekOfYear];
}

- (NSInteger)quarter {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitQuarter fromDate:self] quarter];
}

- (BOOL)isLeapMonth {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitQuarter fromDate:self] isLeapMonth];
}

- (BOOL)isLeapYear {
    NSUInteger year = self.year;
    return ((year % 400 == 0) || ((year % 100 != 0) && (year % 4 == 0)));
}

- (BOOL)isToday {
    if (fabs(self.timeIntervalSinceNow >= 24 * 60 * 60)) return NO;
    return [NSDate new].day == self.day;
}

- (BOOL)isYesterday {
    NSDate *added = [self dateByAddingDays:-1];
    return [added isToday];
}

- (NSDate *)dateByAddingYears:(NSInteger)years {
    NSCalendar * calendar = [NSCalendar currentCalendar];
    NSDateComponents * components = [[NSDateComponents alloc] init];
    [components setYear:years];
    return [calendar dateByAddingComponents:components toDate:self options:0];
}

- (NSDate *)dateByAddingMonths:(NSInteger)months {
    NSCalendar * calendar = [NSCalendar currentCalendar];
    NSDateComponents * components = [[NSDateComponents alloc] init];
    [components setMonth:months];
    return [calendar dateByAddingComponents:components toDate:self options:0];
}

- (NSDate *)dateByAddingDays:(NSInteger)days {
    NSCalendar * calendar = [NSCalendar currentCalendar];
    NSDateComponents * components = [[NSDateComponents alloc] init];
    [components setDay:days];
    return [calendar dateByAddingComponents:components toDate:self options:0];
}

- (NSDate *)dateByAddingHours:(NSInteger)hours {
    NSCalendar * calendar = [NSCalendar currentCalendar];
    NSDateComponents * components = [[NSDateComponents alloc] init];
    [components setHour:hours];
    return [calendar dateByAddingComponents:components toDate:self options:0];
}

- (NSDate *)dateByAddingMinutes:(NSInteger)minutes {
    NSCalendar * calendar = [NSCalendar currentCalendar];
    NSDateComponents * components = [[NSDateComponents alloc] init];
    [components setMinute:minutes];
    return [calendar dateByAddingComponents:components toDate:self options:0];
}

- (NSDate *)dateByAddingSeconds:(NSInteger)seconds {
    NSCalendar * calendar = [NSCalendar currentCalendar];
    NSDateComponents * components = [[NSDateComponents alloc] init];
    [components setSecond:seconds];
    return [calendar dateByAddingComponents:components toDate:self options:0];
}

@end
