//
//  SecureKeys.m
//  BankExample
//
//  Created by Ilya Nikokoshev on 24/04/15.
//  Copyright (c) 2015 ilya n. All rights reserved.
//

#import "SecureKeys.h"

@implementation SecureKeys

- (instancetype)init {
    if (self = [super init]) {
        SecKeyRef publicKey = NULL;
        SecKeyRef privateKey = NULL;
        
        NSDictionary *keyPairAttr = @{ 
                      (__bridge id)kSecAttrKeyType: (__bridge id)kSecAttrKeyTypeRSA, 
                (__bridge id)kSecAttrKeySizeInBits: @1024
        };
        
        if (0 != SecKeyGeneratePair((__bridge CFDictionaryRef)keyPairAttr, &publicKey, &privateKey)) {
            @throw @"Cannot generate a key pair";
        }

        _privateKey = privateKey;
        _publicKey = publicKey;
    }
    return self;
}

- (void)dealloc {
    if(self.publicKey)  CFRelease(self.publicKey);
    if(self.privateKey) CFRelease(self.privateKey);         
}

@end
