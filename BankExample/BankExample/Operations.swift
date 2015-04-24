//
//  Operation.swift
//  BankExample
//
//  Created by Ilya Nikokoshev on 24/04/15.
//  Copyright (c) 2015 ilya n. All rights reserved.
//

import UIKit

class AuthorizationOperation: NSOperation {
    let loginText: String
    let passwordText: String
    
    init(login: String, password: String) {
        loginText = login
        passwordText = password
    }
    
    override func main() {
        UIAlertView(title: "Authorization", message: "Dummy", delegate: nil, cancelButtonTitle: "Sure").show()
    }
}