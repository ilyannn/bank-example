//
//  AuthorizationTests.swift
//  BankExample
//
//  Created by Ilya Nikokoshev on 24/04/15.
//  Copyright (c) 2015 ilya n. All rights reserved.
//

import XCTest

class AuthorizationTests: XCTestCase {

    func testAuthorization() {
        var authorization = Authorization(
              secureKeys: SecureKeys(),
                  authId: "someone",
                authDate: CurrentUnixTime()
        )
        let json: AnyObject = authorization.JSONObject
        XCTAssert(authorization.from(JSONObject: json), "Signature should verify user")
    }
}