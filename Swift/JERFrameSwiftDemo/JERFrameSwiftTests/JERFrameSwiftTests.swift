//
//  JERFrameSwiftTests.swift
//  JERFrameSwiftTests
//
//  Created by super on 17/12/2017.
//  Copyright © 2017 Jeremy. All rights reserved.
//

import XCTest
@testable import JERFrameSwift

class JERFrameSwiftTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        let view = UIView.init(frame: CGRect.init(x: 100, y: 100, width: 100, height: 100))
        view.size = CGSize.init(width: 50, height: 50)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
