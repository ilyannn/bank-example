//
//  SecureKeys.m
//  BankExample
//
//  Created by Ilya Nikokoshev on 24/04/15.
//  Copyright (c) 2015 ilya n. All rights reserved.
//

// Uses Apple's sample code at https://developer.apple.com/library/ios/samplecode/CryptoExercise/Introduction/Intro.html#//apple_ref/doc/uid/DTS40008019-Intro-DontLinkElementID_2
// Mandatory warning follows.

/*
 
 File: SecKeyWrapper.m
 Abstract: Core cryptographic wrapper class to exercise most of the Security 
 APIs on the iPhone OS. Start here if all you are interested in are the 
 cryptographic APIs on the iPhone OS.
 
 Version: 1.2
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple Inc.
 ("Apple") in consideration of your agreement to the following terms, and your
 use, installation, modification or redistribution of this Apple software
 constitutes acceptance of these terms.  If you do not agree with these terms,
 please do not use, install, modify or redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and subject
 to these terms, Apple grants you a personal, non-exclusive license, under
 Apple's copyrights in this original Apple software (the "Apple Software"), to
 use, reproduce, modify and redistribute the Apple Software, with or without
 modifications, in source and/or binary forms; provided that if you redistribute
 the Apple Software in its entirety and without modifications, you must retain
 this notice and the following text and disclaimers in all such redistributions
 of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may be used
 to endorse or promote products derived from the Apple Software without specific
 prior written permission from Apple.  Except as expressly stated in this notice,
 no other rights or licenses, express or implied, are granted by Apple herein,
 including but not limited to any patent rights that may be infringed by your
 derivative works or by other works in which the Apple Software may be
 incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO
 WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED
 WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN
 COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR
 CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
 GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR
 DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF
 CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF
 APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2008-2009 Apple Inc. All Rights Reserved.
 
 */

#import "SecureKeys.h"

#define kChosenCipherBlockSize	kCCBlockSizeAES128
#define kChosenCipherKeySize	kCCKeySizeAES128
#define kChosenDigestLength		CC_SHA1_DIGEST_LENGTH
#define kTypeOfSigPadding		kSecPaddingPKCS1SHA1

#define MUST_NOT_FAIL(message, code) { if (noErr != code) { @throw message;}}

@implementation SecureKeys

// MARK: Apple methods (with modifications)
+ (NSData *)getHashBytes:(NSData *)plainText {
    CC_SHA1_CTX ctx;
    uint8_t * hashBytes = NULL;
    NSData * hash = nil;
    
    // Malloc a buffer to hold hash.
    hashBytes = malloc( kChosenDigestLength * sizeof(uint8_t) );
    memset((void *)hashBytes, 0x0, kChosenDigestLength);
    
    // Initialize the context.
    CC_SHA1_Init(&ctx);
    // Perform the hash.
    CC_SHA1_Update(&ctx, (void *)[plainText bytes], [plainText length]);
    // Finalize the output.
    CC_SHA1_Final(hashBytes, &ctx);
    
    // Build up the SHA1 blob.
    hash = [NSData dataWithBytes:(const void *)hashBytes length:(NSUInteger)kChosenDigestLength];
    
    if (hashBytes) free(hashBytes);
    
    return hash;
}

- (NSData *)signatureBytesForData:(NSData *)plainText {
    NSData * signedHash = nil;
    
    uint8_t * signedHashBytes = NULL;
    size_t signedHashBytesSize = 0;
    
    SecKeyRef privateKey = self.privateKey;
    signedHashBytesSize = SecKeyGetBlockSize(privateKey);
    
    // Malloc a buffer to hold signature.
    signedHashBytes = malloc( signedHashBytesSize * sizeof(uint8_t) );
    memset((void *)signedHashBytes, 0x0, signedHashBytesSize);
    
    // Sign the SHA1 hash.
    MUST_NOT_FAIL(@"Cannot sign a message", 
                  SecKeyRawSign(	privateKey, 
                                kTypeOfSigPadding, 
                                (const uint8_t *)[[[self class] getHashBytes:plainText] bytes], 
                                kChosenDigestLength, 
                                (uint8_t *)signedHashBytes, 
                                &signedHashBytesSize
                                )
                  );
    
    // Build up signed SHA1 blob.
    signedHash = [NSData dataWithBytes:(const void *)signedHashBytes length:(NSUInteger)signedHashBytesSize];
    
    if (signedHashBytes) free(signedHashBytes);
    
    return signedHash;
}

- (BOOL)verifySignatureOf:(NSData *)plainText signature:(NSData *)sig {
    size_t signedHashBytesSize = 0;
    SecKeyRef publicKey = self.publicKey;
    
    // Get the size of the assymetric block.
    signedHashBytesSize = SecKeyGetBlockSize(publicKey);
    
    return noErr == SecKeyRawVerify(publicKey, 
                                  kTypeOfSigPadding, 
                                  (const uint8_t *)[[[self class] getHashBytes:plainText] bytes],
                                  kChosenDigestLength, 
                                  (const uint8_t *)[sig bytes],
                                  signedHashBytesSize
                    );
    
}

// MARK: - Our wrappers
- (instancetype)init {
    if (self = [super init]) {
        
        NSDictionary *keyPairAttr = @{ 
                      (__bridge id)kSecAttrKeyType: (__bridge id)kSecAttrKeyTypeRSA, 
                (__bridge id)kSecAttrKeySizeInBits: @1024
        };
        
        MUST_NOT_FAIL(@"Cannot generate a key pair", 
                SecKeyGeneratePair(
                                   (__bridge CFDictionaryRef)keyPairAttr, 
                                   &_publicKey, 
                                   &_privateKey
                                   )
                )
    }
    return self;
}

- (id __nullable)initWithData:(NSData * __nonnull)data passphrase:(NSString *)passphrase {
    if (self = [super init]) {
        NSMutableDictionary *options = [NSMutableDictionary new];
        options[(__bridge id)kSecImportExportPassphrase] = passphrase;
        CFArrayRef items = CFArrayCreate(NULL, 0, 0, NULL);
        
        OSStatus securityError = SecPKCS12Import((__bridge CFDataRef)data,
                                                 (__bridge CFDictionaryRef)options, 
                                                 &items);
        
        if (noErr != securityError || CFArrayGetCount(items) == 0) {
            return nil;
        }
        
        CFDictionaryRef identityDict = CFArrayGetValueAtIndex(items, 0);
        SecIdentityRef identityApp =
        (SecIdentityRef)CFDictionaryGetValue(identityDict, kSecImportItemIdentity);
        
        SecIdentityCopyPrivateKey(identityApp, &_privateKey);
    }
    return self;
    
}

- (void)dealloc {
    if(self.publicKey)  CFRelease(self.publicKey);
    if(self.privateKey) CFRelease(self.privateKey);         
}

- (NSString *)base64SignatureStringForMessage:(NSString *)message {
    NSData *encoded = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSData *signature = [self signatureBytesForData:encoded];
    return [signature base64EncodedStringWithOptions:0];
}

- (BOOL)verifyBase64Signature:(NSString *)base64Signature forMessage:(NSString *)message {
    if (!base64Signature) {
        return NO;
    }
    
    NSData *signature = [[NSData alloc] initWithBase64EncodedString:base64Signature options:0];
    if (!signature) { 
        return NO;
    }

    NSData *encoded = [message dataUsingEncoding:NSUTF8StringEncoding];
    if (!encoded) {
        return NO;
    }
    
    return [self verifySignatureOf:encoded signature:signature];
}

@end
