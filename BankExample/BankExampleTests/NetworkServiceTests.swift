//
//  NetworkServiceTests.swift
//  BankExample
//
//  Created by Ilya Nikokoshev on 24/04/15.
//  Copyright (c) 2015 ilya n. All rights reserved.
//

import XCTest

class NetworkServiceTests: XCTestCase {

    func testMockServerDate() {
        let service1 = MockNetworkService()
        let service2 = MockNetworkService()
        XCTAssert(abs(service1.getServerDate() - service2.getServerDate()) < 1000)
    }
    
    func testRealServerURL() {
        let service = RealNetworkService(server: "example.com")
        XCTAssertNotNil(service)
    }
}