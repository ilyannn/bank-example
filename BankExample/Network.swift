//
//  Network .swift
//  BankExample
//
//  Created by Ilya Nikokoshev on 24/04/15.
//  Copyright (c) 2015 ilya n. All rights reserved.
//

import Foundation

 
/// A production app should also handle errors.
class NetworkService {
    
    class func networkServiceFromSettings() -> NetworkService {
        return MockNetworkService()
        // TODO: generate real network service 
    }
    
    func getServerDate() -> time_t {
        fatalError("abstract method")
    }
    
    func post(authorizationObject object: Authorization) -> Bool {
        fatalError("abstract method")
    }
}

class MockNetworkService: NetworkService {
    let TimeError: time_t = 100
    
    override func getServerDate() -> time_t {
        return CurrentUnixTime() + time_t(arc4random_uniform(UInt32(TimeError))) - TimeError/2
    }
    
    override func post(authorizationObject object: Authorization) -> Bool {
        // How to test with the mock service?
        return arc4random_uniform(2) == 0
    }
}

/// These methods block, which they shouldn't do in the production app.
class RealNetworkService {
    
    let serverURL: NSURL?
    
    init (server: String) {
        serverURL = NSURL(string: server)
    }
    
    // TODO: network service
}

