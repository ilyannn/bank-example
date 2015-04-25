//
//  Operation.swift
//  BankExample
//
//  Created by Ilya Nikokoshev on 24/04/15.
//  Copyright (c) 2015 ilya n. All rights reserved.
//

import UIKit

private let PrivateKeyData = NSData(contentsOfFile: SettingsInformation.keyFilePath())!

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
        let message, title: String
        
        if let decryptedKey = SecureKeys(data: PrivateKeyData, passphrase: passwordText) {
            
            let object = Authorization(
                secureKeys: decryptedKey,
                    authId: loginText,
                  authDate: networkService.getServerDate()
            )
            
            let success = networkService.post(authorizationObject: object)            

            title = "Network Result"
            message = success ? "Successfully authorized." : "Authorization did not succeed. Please try again using different credentials."

        } else {
            title = "Incorrect Password"
            message = "We were unable to decrypt the certificate file. Please try again using a different passphrase."
        }

        UIAlertView(  title: title, 
                    message: message, 
                   delegate: nil, 
          cancelButtonTitle: "Got It"
        ).show()
    }
}