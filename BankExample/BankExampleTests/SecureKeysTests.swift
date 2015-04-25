//
//  BankExampleTests.swift
//  BankExampleTests
//
//  Created by Ilya Nikokoshev on 24/04/15.
//  Copyright (c) 2015 ilya n. All rights reserved.
//

import XCTest

class SecureKeysTests: XCTestCase {
    
    let secureKeys = SecureKeys()
    let testMessage = "something"

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testKeyGeneration() {
        XCTAssertNotNil(secureKeys.publicKey,  "Public key should be generated")
        XCTAssertNotNil(secureKeys.privateKey, "Private key should be generated")
    }
    
    func testSignature() {
        let signature = secureKeys.base64SignatureStringForMessage(testMessage)
        XCTAssertLessThan(6 * count(signature) - 1024, 24,  "Base64 enconding length must equal to the next number up from block size/6 that is divisible by 4")
        XCTAssert(secureKeys.verifyBase64Signature(signature, forMessage: testMessage))
    }

    func testFalseSignature() {
        let signature = secureKeys.base64SignatureStringForMessage(testMessage + " else")
        XCTAssertFalse(secureKeys.verifyBase64Signature(signature, forMessage: testMessage))
    }

    func importKey(path: String, passphrase: String) -> Bool {
        let data = NSData(contentsOfFile: path)
        XCTAssertNotNil(data, "Can't open the resource")
        if let data = data {
            return SecureKeys(data: data, passphrase: passphrase) != nil
        } else {
            return false
        }
    }
    
    func testImportKey() {
        let path: String? = SettingsInformation.keyFilePath()
        XCTAssertNotNil(path, "Can't get the resource")
        if let path = path {
            XCTAssertTrue(importKey(path, passphrase: "xxx"))
            XCTAssertFalse(importKey(path, passphrase: "zzz"))
        }
    }
}
