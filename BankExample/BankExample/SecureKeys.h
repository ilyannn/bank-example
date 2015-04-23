//
//  SecureKeys.h
//  BankExample
//
//  Created by Ilya Nikokoshev on 24/04/15.
//  Copyright (c) 2015 ilya n. All rights reserved.
//

@import Foundation;
@import Security;

/// RSA key pair
@interface SecureKeys : NSObject

/// Creates a test pair.
- (instancetype)init;

@property(readonly) SecKeyRef publicKey;
@property(readonly) SecKeyRef privateKey;

@end
