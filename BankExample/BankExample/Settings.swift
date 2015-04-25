//
//  Settings.swift
//  BankExample
//
//  Created by Ilya Nikokoshev on 25/04/15.
//  Copyright (c) 2015 ilya n. All rights reserved.
//

import Foundation

class SettingsInformation {
    class func networkService() -> NetworkService {
        return MockNetworkService()
        // TODO: generate real network service 
    }
    
    class func keyFilePath() -> String! {
        return NSBundle.mainBundle().pathForResource("key", ofType: "pfx")
    }
}
