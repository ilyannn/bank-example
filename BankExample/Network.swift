//
//  Network .swift
//  BankExample
//
//  Created by Ilya Nikokoshev on 24/04/15.
//  Copyright (c) 2015 ilya n. All rights reserved.
//

import Foundation

class SettingsInformation {
    class func networkService() -> NetworkService {
        return MockNetworkService()
        // TODO: generate real network service 
    }
}

/// A production app should also handle errors.
protocol NetworkService {
    func getServerDate() -> time_t     
    func post(authorizationObject object: Authorization) -> Bool 
}

class MockNetworkService: NetworkService {
    let TimeError: time_t = 100
    
    func getServerDate() -> time_t {
        return CurrentUnixTime() + time_t(arc4random_uniform(UInt32(TimeError))) - TimeError/2
    }
    
    func post(authorizationObject object: Authorization) -> Bool {
        // How to test with the mock service?
        return arc4random_uniform(2) == 0
    }
}

/// These methods block, which they shouldn't do in the production app.
class RealNetworkService {
    
    let serverURL: NSURL
    
    init? (server: String) {
        
        if let URL = NSURL(string: server) {
            serverURL = URL
        } else {
            serverURL = NSURL(string: "http://does-not-matter.com")!
            return nil
        }
    }
    
    // TODO: network service
}

