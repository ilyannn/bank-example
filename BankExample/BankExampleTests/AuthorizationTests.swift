//
//  AuthorizationTests.swift
//  BankExample
//
//  Created by Ilya Nikokoshev on 24/04/15.
//  Copyright (c) 2015 ilya n. All rights reserved.
//

import XCTest

func ExampleAuthorizationFactory() -> Authorization {  
    
    return Authorization(
        secureKeys: SecureKeys(),
            authId: "someone",
          authDate: CurrentUnixTime()
    )
}

class AuthorizationTests: XCTestCase {
    
    func authorizationResult(corruptDate: time_t = 0, corruptID:String = "") -> Bool {
        var authorization = ExampleAuthorizationFactory()
         
        var json = authorization.JSONObject
            
        if let userID = json["userId"] as? String {
            json["userId"] = userID + corruptID
        }
        
        if let authDate = json["date"] as? NSNumber {
            json["date"] = authDate.integerValue + corruptDate
        }
        
        return authorization.from(JSONObject: json)
        
    }
    
    func testAuthorizationVerificationPositive() {
        XCTAssertTrue(authorizationResult(), "Signature should verify user")
    }

    func testAuthorizationVerificationNegative() {
        XCTAssertFalse(authorizationResult(corruptDate: 1))
        XCTAssertFalse(authorizationResult(corruptID: ", Jr."))
        XCTAssertFalse(authorizationResult(corruptDate: 5, corruptID: ", Esq."))
    }

}