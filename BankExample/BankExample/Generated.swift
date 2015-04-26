//
//  Generated.swift
//  BankExample
//
//  Created by Ilya Nikokoshev on 26/04/15.
//  Copyright (c) 2015 ilya n. All rights reserved.
//

import Foundation

typealias ObjectPointer = AutoreleasingUnsafeMutablePointer<AnyObject?>

class ValidationError: NSError {
    var _userInfo: [String: AnyObject] = [:]
    
    init(reason: String = "Invalid field value") {
        super.init(domain: "ValidationError", code: 1, userInfo: [NSLocalizedFailureReasonErrorKey: reason])
        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("not implemented")
    }
    
    override var userInfo: [NSObject: AnyObject]? { return _userInfo }
}

class Generated: NSObject {
    
    var keys_generated: [String] {
        return []        
    }
    
    var JSONObject: [String: AnyObject] {
        return dictionaryWithValuesForKeys(keys_generated) as! [String: AnyObject]
    }
    
    func validate() -> ValidationError? {
        return nil
    }
    
    func from(#JSONObject: AnyObject) -> Bool {
        var errors: [NSError] = []
        
        if let dict = JSONObject as? [String: AnyObject] {
            
            for key in keys_generated {
                var value: AnyObject? = dict[key]
                var reported: NSError?
                
                if validateValue(&value, forKey: key, error: &reported) {
                    setValue(value, forKey: key)
                } else {
                    let error = (reported as? ValidationError) ?? ValidationError()
                    
                    var info = error._userInfo ?? [:]
                    info["key"] = key
                    info["value"] = value
                    error._userInfo = info
                    
                    errors.append(error)
                }
            }
            
            if let error = validate() {
                errors.append(error)
            }            
        }
        
        if errors.count > 0 {
            NSLog("\(errors.count) errors were encountered during validation: %@", errors)
            return false
        }
        
        return true
    }
    
    func validate<T: NSObject>(
        value: ObjectPointer, 
        allowNil: Bool = false, 
        error: NSErrorPointer = nil, 
        @noescape
        validator:  T -> NSError? = { _ in return nil }
        ) -> Bool 
    {
        if let object: AnyObject = value.memory  {
            
            if !object.isKindOfClass(T.self) {
                return false
            }
            
            if let invalid = validator(object as! T) {
                if error != nil {
                    error.memory = invalid
                }
                return false
            } else {
                return true
            }
            
        } else {
            return allowNil
        }
    }
}