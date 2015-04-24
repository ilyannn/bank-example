//
//  Authorization.swift
//  BankExample
//
//  Created by Ilya Nikokoshev on 24/04/15.
//  Copyright (c) 2015 ilya n. All rights reserved.
//

import Foundation

class Authorization: NSObject {
    let secureKeys: SecureKeys

    init(keys: SecureKeys) {
         secureKeys = keys
    }
    
    func toJSONObject() -> AnyObject {
        return [
            "userId": authId,
              "date": authDate,
             "proof": secureKeys.base64SignatureStringForMessage(authMessage)
        ]
    }
    
    func from(JSONObject: AnyObject) -> Bool {
        if let dict = JSONObject as? [String: AnyObject] {
            authId = dict["userId"] as? String ?? "" 
            authDate = (dict["date"] as? NSNumber ?? 0).integerValue
            return secureKeys.verifyBase64Signature(dict["proof"] as? String, forMessage: authMessage) 
        }
        return false
    }
    
    var authId = ""
    var authDate: time_t = 0
    var authMessage: String { return authId + ":" + String(authDate) }
}