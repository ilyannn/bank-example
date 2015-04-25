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
    
    func testGenerateServiceURL() {
        let service = RealNetworkService(server: "example.com")
        XCTAssertNotNil(service)
    }
    
    let realServer = "https://raw.githubusercontent.com/ilyannn/bank-example/master/TestService"
    
    func testRealServiceDate() {
        if let service = RealNetworkService(server: realServer) {
            let time = service.getServerDate()
            XCTAssertEqual(time, 1429997160)
            let date = NSDate(timeIntervalSince1970: NSTimeInterval(time))
            let calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)!
            let components = calendar.components(.CalendarUnitYear, fromDate: date)
            XCTAssertEqual(components.year, 2015)
        }
    }
    
}