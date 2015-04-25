//
//  Network .swift
//  BankExample
//
//  Created by Ilya Nikokoshev on 24/04/15.
//  Copyright (c) 2015 ilya n. All rights reserved.
//

import Foundation

/// A production app should also handle errors.
protocol NetworkService {
    func getServerDate() -> time_t     
    func post(authorizationObject object: Authorization, callback: (Bool) -> ()) 
}

class MockNetworkService: NetworkService {
    let TimeError: time_t = 100
    
    func getServerDate() -> time_t {
        return CurrentUnixTime() + time_t(arc4random_uniform(UInt32(TimeError))) - TimeError/2
    }
    
    func post(authorizationObject object: Authorization, callback: (Bool) -> ()) {
        // How to test with the mock service?
        callback(arc4random_uniform(2) == 0)
    }
}

/// These methods block, which they shouldn't do in the production app.
class RealNetworkService: NSObject, NetworkService {
    
    let serverURL: NSURL! // Optional to make writing an optional init easier.
    var networkSession: NSURLSession!
    
    let networkQueue = NSOperationQueue.mainQueue()
    var callbacks: [NSURLSessionTask: (Bool) -> ()] = [:]
    
    init? (server: String) {
        
        serverURL = NSURL(string: server)        
        super.init()

        if serverURL == nil {
            return nil
        }
        
        networkSession = NSURLSession(configuration: nil, delegate: self, delegateQueue: networkQueue)
    }
    
    func getServerDate() -> time_t {
        let url = serverURL.URLByAppendingPathComponent("/api/now")
        let response = NSData(contentsOfURL: url)
        let string = NSString(data: response!, encoding: NSUTF8StringEncoding)
        return string!.integerValue
    }
    
    func post(authorizationObject object: Authorization, callback: (Bool) -> ()) {
        
        let url = serverURL.URLByAppendingPathComponent("/api/login")
        let json = object.JSONObject
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(json, options: .PrettyPrinted, error: nil)!
        request.HTTPMethod = "POST"
        
        let task = networkSession.dataTaskWithRequest(request)
        callbacks[task] = callback
        task.resume()
    }
    
}

extension RealNetworkService: NSURLSessionDelegate, NSURLSessionTaskDelegate {
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        let response = task.response as? NSHTTPURLResponse
        let callback = callbacks[task]
        let result: Bool
        
        switch response?.statusCode {
            case .Some(200): result = true
            case .Some(403): result = false
                 case .None: fatalError("This is insane")
                    default: fatalError("That's not what we agreed to")
        }
        
        callback!(result)
    }
}

