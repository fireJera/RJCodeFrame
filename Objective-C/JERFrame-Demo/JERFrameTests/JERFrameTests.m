//
//  JERFrameTests.m
//  JERFrameTests
//
//  Created by super on 17/12/2017.
//  Copyright © 2017 Jeremy. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "UIView+JER_Frame.h"

@interface JERFrameTests : XCTestCase

@end

@implementation JERFrameTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    NSAssert(view.origin.x == 100, @"origin x error");
    NSAssert(view.origin.y == 100, @"origin y error");
    NSAssert(view.size.width == 100, @"error");
    NSAssert(view.size.height == 100, @"error");
    NSAssert(view.width == 100, @"width error");
    NSAssert(view.height == 100, @"height error");
    NSAssert(view.top == 100, @"top error");
    NSAssert(view.bottom == 200, @"bottom error");
    NSAssert(view.left == 100, @"left error");
    NSAssert(view.right == 200, @"right error");
    NSAssert(view.centerX == 150, @"centerX error");
    NSAssert(view.centerY == 150, @"centerY error");
}

- (void)testSetMethod {
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    view.top = 50;
    NSAssert(view.frame.origin.y == 50, @"set bottom error");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
