//
//  ViewController.swift
//  BankExample
//
//  Created by Ilya Nikokoshev on 24/04/15.
//  Copyright (c) 2015 ilya n. All rights reserved.
//

import UIKit

// MARK: Screen construction
class LoginViewController: UIViewController {

    @IBOutlet weak var loginField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var okButton: UIButton!
    
    let settingsInformation = SettingsInformation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateControlAppearance()
    }
}

// MARK: On-screen events
extension LoginViewController: UITextFieldDelegate {
    
    @IBAction func valueChangedInField(sender: UITextField) {
        updateControlAppearance()
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch (textField) {
               case loginField: passwordField.becomeFirstResponder()
            case passwordField: if okButton.enabled { proceedWithForm(textField) }
                       default: break;
        }
        return false
    }    

    func updateControlAppearance() {
        okButton.enabled = loginField.text != "" && passwordField.text != ""
    }

    @IBAction func proceedWithForm(sender: AnyObject) {
        performAuthorization()
        
        loginField.resignFirstResponder()
        passwordField.resignFirstResponder()
        passwordField.text = ""
        updateControlAppearance()
    }    
}

// MARK: Core logic 
extension LoginViewController {
    
    func performAuthorization() {

        AuthorizationOperation(
               login: loginField.text, 
            password: passwordField.text, 
              target: settingsInformation.networkService
        ).start()        
    }
    
}