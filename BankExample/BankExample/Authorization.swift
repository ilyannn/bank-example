//
//  Authorization.swift
//  BankExample
//
//  Created by Ilya Nikokoshev on 24/04/15.
//  Copyright (c) 2015 ilya n. All rights reserved.
//

import Foundation

// BEGIN GENERATED CODE: DO NOT EDIT MANUALLY
class Authorization_Generated: Generated { 
    
    // Object schema
    override var keys_generated: [String] {
        return ["userId", "date", "proof"]        
    }
    

    // Generated properties
    private(set) var userId = ""
    private(set) var proof = ""
    private(set) var date = 0


    // Validation (Objective-C wrappers)
    func validateUserId(value: ObjectPointer, error: NSErrorPointer) -> Bool {
        return validate(value) { (userId: NSString) in
            validate(userId: userId as String) 
        } 
    }
    
    func validateProof(value: ObjectPointer, error: NSErrorPointer) -> Bool {
        return validate(value) { (proof: NSString) in
            validate(proof: proof as String) 
        } 
    }
    
    func validateDate(value: ObjectPointer, error: NSErrorPointer) -> Bool {
        return validate(value) { (date: NSNumber) in
            validate(date: date.integerValue) 
        } 
    }
    
    
    // Validation (native Swift)
    func validate(#userId: String) -> ValidationError? {
        return nil
    }
    
    func validate(#proof: String) -> ValidationError? {
        return nil
    }
    
    func validate(#date: Int) -> ValidationError? {
        return nil
    }
    
}
// END GENERATED CODE


/// An authorization to be trasmitted to the service.
class Authorization: Authorization_Generated {

    var secureKeys: SecureKeys
    
    var authMessage: String { 
        return userId + ":" + String(date) 
    }

    init(secureKeys: SecureKeys,
             authId: String,
           authDate: time_t) 
    {
        self.secureKeys = secureKeys

        super.init()
        
        self.userId = authId
        self.date   = authDate
        self.proof  = secureKeys.base64SignatureStringForMessage(authMessage)
    }
    
    override func validate() -> ValidationError? {
        if secureKeys.verifyBase64Signature(proof, forMessage: authMessage) {
            return nil
        } else {
            return ValidationError(reason: "Signature cannot be verified")
        }
    }
    
}