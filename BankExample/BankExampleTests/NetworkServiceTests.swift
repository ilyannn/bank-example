//
//  NetworkServiceTests.swift
//  BankExample
//
//  Created by Ilya Nikokoshev on 24/04/15.
//  Copyright (c) 2015 ilya n. All rights reserved.
//

import XCTest

private let RealServer = "https://raw.githubusercontent.com/ilyannn/bank-example/master/TestService"

class NetworkServiceTests: XCTestCase {

    func testMockServerDate() {
        let service1 = MockNetworkService()
        let service2 = MockNetworkService()
        XCTAssert(abs(service1.getServerDate() - service2.getServerDate()) < 1000)
    }
    
    let realService = RealNetworkService(server: RealServer)

    func testGenerateServiceURL() {
        let service = RealNetworkService(server: "example.com")
        XCTAssertNotNil(service)
        XCTAssertNotNil(realService)
    }
    
    func testRealServiceDate() {
        if let service = realService {
            let time = service.getServerDate()
            XCTAssertEqual(time, 1429997160)
            
            let date = NSDate(timeIntervalSince1970: NSTimeInterval(time))
            let calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)!
            let components = calendar.components(.CalendarUnitYear, fromDate: date)
            XCTAssertEqual(components.year, 2015)
        }
    }

    func testRealServiceLogin() {
        
        if let service = realService {
            
            let auth = ExampleAuthorizationFactory()            
            let expectation = expectationWithDescription("Wait for GitHub reply")

            NSLog("I'm about to post this JSON: \(auth.JSONObject)")
            
            service.post(authorizationObject: auth) { success in
                XCTAssertTrue(success, "For some reason, GitHub returns 200 OK")
                expectation.fulfill()
            }
            
            waitForExpectationsWithTimeout(20) { error in 
                if let error = error {
                    NSLog("test error: %@", error)
                }
            }
        }
    }
}