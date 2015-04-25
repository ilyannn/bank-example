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
    let networkService: NetworkService
    
    init(login: String, password: String, target: NetworkService) {
        loginText = login
        passwordText = password
        networkService = target
    }
    
    override func main() {
        let object = Authorization(
            secureKeys: SecureKeys(),  // TODO: retrieve the keys
                authId: loginText,
              authDate: networkService.getServerDate()
        )
        
        let success = networkService.post(authorizationObject: object)
            
        UIAlertView(  title: "Authorization", 
                    message: success ? "Successfully authorized" : "Please try again", 
                   delegate: nil, 
          cancelButtonTitle: "Got It"
        ).show()
    }
}