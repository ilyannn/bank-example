//
//  Authorization.swift
//  BankExample
//
//  Created by Ilya Nikokoshev on 24/04/15.
//  Copyright (c) 2015 ilya n. All rights reserved.
//

import Foundation

/// An authorization to be trasmitted to the service.
struct Authorization {
    // Stored properties
    var secureKeys: SecureKeys
    var authId: String
    var authDate: time_t
    
    // Computed properties
    var authMessage: String { return authId + ":" + String(authDate) }

    var JSONObject: AnyObject {
        return [
            "userId": authId,
              "date": authDate,
             "proof": secureKeys.base64SignatureStringForMessage(authMessage)
        ]
    }
    
    mutating func from(#JSONObject: AnyObject) -> Bool {
        if let dict = JSONObject as? [String: AnyObject] {
            authId = dict["userId"] as? String ?? "" 
            authDate = (dict["date"] as? NSNumber ?? 0).integerValue
            return secureKeys.verifyBase64Signature(dict["proof"] as? String, forMessage: authMessage) 
        }
        return false
    }
    
}