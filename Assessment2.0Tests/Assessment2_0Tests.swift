//
//  Assessment2_0Tests.swift
//  Assessment2.0Tests
//
//  Created by Kayn Critchley on 15/4/19.
//  Copyright © 2019 Kayn Critchley. All rights reserved.
//

import XCTest
@testable import Assessment2_0

class Assessment2_0Tests: XCTestCase {


    func testaddObject() {
        let location = Location(name:"Hey", address: "Brisbane", latitude: -27.546, longitude: 153.9)
        XCTAssertEqual(location.name, "Hey")
        XCTAssertEqual(location.address, "Brisbane")
        XCTAssertEqual(location.latitude, -27.546)
        XCTAssertEqual(location.longitude, 153.9)
    }
    /// test if added object is nil
    func testaddObjectnil() {
        let location = Location(name:"Hey", address: "Brisbane", latitude: -27.546, longitude: 153.9)
        XCTAssertNotNil(location.name, "Hey")
        XCTAssertNotNil(location.address, "Brisbane")
        XCTAssertNotNil(location.latitude, "-27.546")
        XCTAssertNotNil(location.longitude, "153.9")
    }


}
