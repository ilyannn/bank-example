//
//  Settings.swift
//  BankExample
//
//  Created by Ilya Nikokoshev on 25/04/15.
//  Copyright (c) 2015 ilya n. All rights reserved.
//

import Foundation


// MARK: Settings administration
class SettingsInformation: NSObject {
    
    let userDefaults = NSUserDefaults.standardUserDefaults()

    override init() {
        super.init()
        
        NSNotificationCenter.defaultCenter().addObserver(self, 
            selector: "defaultsChanged:", 
                name: NSUserDefaultsDidChangeNotification, 
              object: nil)
    }
    
    @objc(defaultsChanged:) func defaultsChanged(sender: AnyObject!) {
        userDefaults.synchronize()
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

// MARK: Specific settings
extension SettingsInformation {
    
    var serverURLString: String? {
        let server = userDefaults.stringForKey("srv")
        return server == "" ? nil : server
    }
    
    func networkService() -> NetworkService {        
        if let server = serverURLString {
            return RealNetworkService(server: server)!
        } else {
            return MockNetworkService()
        }
    }
    
    class func keyFilePath() -> String! {
        return NSBundle.mainBundle().pathForResource("key", ofType: "pfx")
    }
    
}
