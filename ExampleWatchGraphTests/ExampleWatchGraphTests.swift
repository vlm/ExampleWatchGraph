//
//  ExampleWatchGraphTests.swift
//  ExampleWatchGraphTests
//
//  Created by Lev Walkin on 11/29/15.
//  Copyright © 2015 Lev Walkin. All rights reserved.
//

import XCTest
@testable import ExampleWatchGraph

class ExampleWatchGraphTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testEmpty() {
        let gd = GraphData.init(graphTimeSpan: 5)
        XCTAssertEqual(gd.normalValues(currentTime: 000.0).count, 0)
        XCTAssertEqual(gd.normalValues(currentTime: 001.0).count, 0)
        XCTAssertEqual(gd.normalValues(currentTime: 100.0).count, 0)
    }
    
    func test1Point() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let gd = GraphData.init(graphTimeSpan: 5)
        gd.addPoint(timeStamp: 0, value: 1)
        let vals = gd.normalValues(currentTime: 5.0)
        XCTAssertEqual(vals.count, 1)
        XCTAssertEqualWithAccuracy(vals[0].0, 0.0, accuracy: 0.01)
        XCTAssertEqualWithAccuracy(vals[0].1, 1.0, accuracy: 0.01)
    }
    
    func test2Points() {
        let gd = GraphData.init(graphTimeSpan: 5)
        gd.addPoint(timeStamp: 0, value: 1)
        gd.addPoint(timeStamp: 5, value: 1)
        let vals = gd.normalValues(currentTime: 5.0)
        XCTAssertEqual(vals.count, 2)
        XCTAssertEqualWithAccuracy(vals[0].0, 0.0, accuracy: 0.01)
        XCTAssertEqualWithAccuracy(vals[0].1, 1.0, accuracy: 0.01)
        XCTAssertEqualWithAccuracy(vals[1].0, 1.0, accuracy: 0.01)
        XCTAssertEqualWithAccuracy(vals[1].1, 1.0, accuracy: 0.01)
    }
    
    func test3Points1() {
        let gd = GraphData.init(graphTimeSpan: 5)
        gd.addPoint(timeStamp: 0, value: 1)
        gd.addPoint(timeStamp: 1, value: 1)
        gd.addPoint(timeStamp: 6, value: 1)
        let vals = gd.normalValues(currentTime: 7.0)
        XCTAssertEqual(vals.count, 2)
        XCTAssertEqualWithAccuracy(vals[0].0, -0.2, accuracy: 0.01)
        XCTAssertEqualWithAccuracy(vals[0].1,  1.0, accuracy: 0.01)
        XCTAssertEqualWithAccuracy(vals[1].0,  0.8, accuracy: 0.01)
        XCTAssertEqualWithAccuracy(vals[1].1,  1.0, accuracy: 0.01)
    }
    
    func test3Point2() {
        let gd = GraphData.init(graphTimeSpan: 5)
        gd.addPoint(timeStamp: 8, value: 1)
        gd.addPoint(timeStamp: 10, value: 1)
        gd.addPoint(timeStamp: 15, value: 1)
        let vals = gd.normalValues(currentTime: 15)
        XCTAssertEqual(vals.count, 2)
        XCTAssertEqualWithAccuracy(vals[0].0, 0.0, accuracy: 0.01)
        XCTAssertEqualWithAccuracy(vals[0].1, 1.0, accuracy: 0.01)
        XCTAssertEqualWithAccuracy(vals[1].0, 1.0, accuracy: 0.01)
        XCTAssertEqualWithAccuracy(vals[1].1, 1.0, accuracy: 0.01)
    }
    
    func testMaxNormalizing() {
        let gd = GraphData.init(graphTimeSpan: 5)
        gd.addPoint(timeStamp: 1, value: 1)
        gd.addPoint(timeStamp: 2, value: 3)
        gd.addPoint(timeStamp: 3, value: 5)
        gd.addPoint(timeStamp: 4, value: 4)
        let vals = gd.normalValues(currentTime: 5)
        XCTAssertEqual(vals.count, 4)
        XCTAssertEqualWithAccuracy(vals[0].0, 0.2, accuracy: 0.01)
        XCTAssertEqualWithAccuracy(vals[0].1, 0.2, accuracy: 0.01)
        XCTAssertEqualWithAccuracy(vals[1].0, 0.4, accuracy: 0.01)
        XCTAssertEqualWithAccuracy(vals[1].1, 0.6, accuracy: 0.01)
        XCTAssertEqualWithAccuracy(vals[2].0, 0.6, accuracy: 0.01)
        XCTAssertEqualWithAccuracy(vals[2].1, 1.0, accuracy: 0.01)
        XCTAssertEqualWithAccuracy(vals[3].0, 0.8, accuracy: 0.01)
        XCTAssertEqualWithAccuracy(vals[3].1, 0.8, accuracy: 0.01)
    }
    
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
