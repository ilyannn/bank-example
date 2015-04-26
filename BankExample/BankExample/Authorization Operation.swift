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
    let networkServiceFactory: () -> NetworkService
    
    init(login: String, password: String, target factory: () -> NetworkService) {
        loginText = login
        passwordText = password
        networkServiceFactory = factory
    }
    
    override func main() {
        let alert = UIAlertView()
        alert.addButtonWithTitle("Got It")
        
        if let decryptedKey = SecureKeys(data: PrivateKeyData, passphrase: passwordText) {

            let networkService = networkServiceFactory()
            
            let object = Authorization(
                secureKeys: decryptedKey,
                    authId: loginText,
                  authDate: networkService.getServerDate()
            )
            
            networkService.post(authorizationObject: object)  { success in
                
                alert.title = "Network Result"
                alert.message = success ? "Successfully authorized." 
                                : "Authorization did not succeed. Please try again using different credentials."
                
                alert.show()
            }

        } else {
            alert.title = "Incorrect Password"
            alert.message = "We were unable to decrypt the certificate file. Please try again using a different passphrase."
            alert.show()
        }

    }
}