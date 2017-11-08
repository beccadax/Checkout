//
//  LibCryptoWrapper.h
//  Checkout
//
//  Created by Brent Royal-Gordon on 11/5/17.
//  Copyright © 2017 Architechies. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSErrorDomain const _Nonnull OpenSSLErrorDomain;
extern NSErrorDomain const _Nonnull OpenSSLWrapperErrorDomain;

typedef NS_ERROR_ENUM(OpenSSLWrapperErrorDomain, OpenSSLWrapperErrorCode) {
    OpenSSLWrapperErrorWrongObjectTag = 1,
    OpenSSLWrapperErrorPartiallyScannedObject
};

extern NSErrorUserInfoKey const _Nonnull OpenSSLObjectTagKey;

@class _PKCS7Signed;
@class _X509Store;

@interface _BIO: NSObject

- (nullable instancetype)initWithData:(nonnull NSData*)data error:(NSError *_Nullable *_Nullable)error;

@property (readonly) BOOL isAtEnd;
@property (readonly) NSInteger offsetInFile;

- (nullable NSData*)readDataOfLength:(NSInteger)maxLength error:(NSError *_Nullable *_Nullable)error;

@end

@interface _PKCS7: NSObject

- (nullable instancetype)initWithData:(nonnull _BIO*)bio error:(NSError *_Nullable *_Nullable)error;

- (BOOL)getSigned:(_PKCS7Signed*_Nullable *_Nullable)signed7 error:(NSError *_Nullable *_Nullable)error NS_REFINED_FOR_SWIFT;
- (BOOL)getData:(NSData *_Nullable *_Nullable)data error:(NSError *_Nullable *_Nullable)error NS_REFINED_FOR_SWIFT;

- (BOOL)verifyWithCertificates:(nonnull _X509Store*)certificateStore error:(NSError *_Nullable *_Nullable)error NS_SWIFT_NAME(verify(with:));

@end

@interface _PKCS7Signed: NSObject

- (nullable _PKCS7*)contentsWithError:(NSError *_Nullable *_Nullable)error;

@end

@interface _X509: NSObject

- (nullable instancetype)initWithData:(nonnull _BIO*)bio error:(NSError *_Nullable *_Nullable)error;

@end

@interface _X509Store: NSObject

- (nonnull instancetype)init;
- (BOOL)addCertificate:(nonnull _X509*)cert error:(NSError *_Nullable *_Nullable)error;

@end

typedef NS_ENUM(int, _ASN1ScannerObjectTag) {
    _ASN1ScannerObjectTagSet = 17,             // V_ASN1_SET
    _ASN1ScannerObjectTagSequence = 16,        // V_ASN1_SEQUENCE
    _ASN1ScannerObjectTagInteger = 2,          // V_ASN1_INTEGER
    _ASN1ScannerObjectTagOctetString = 4,      // V_ASN1_OCTET_STRING
    _ASN1ScannerObjectTagUTF8String = 12,      // V_ASN1_UTF8STRING
    _ASN1ScannerObjectTagIA5String = 22,       // V_ASN1_IA5STRING
};

@interface _ASN1Scanner: NSObject

- (nonnull instancetype)initWithData:(nonnull NSData*)data;

- (BOOL)scanObjectWithTag:(_ASN1ScannerObjectTag)tag scanBlock:(BOOL(^_Nonnull)(_ASN1Scanner*_Nonnull, NSError *_Nullable *_Nullable))scanBlock error:(NSError *_Nullable *_Nullable)error NS_REFINED_FOR_SWIFT;
- (NSInteger)scanRawInteger;
- (nonnull NSData*)scanRawData;

- (BOOL)scanInteger:(NSInteger *_Nullable)outInteger error:(NSError *_Nullable *_Nullable)error NS_REFINED_FOR_SWIFT;
- (BOOL)scanOctetString:(NSData *_Nullable *_Nullable)outOctets error:(NSError *_Nullable *_Nullable)error NS_REFINED_FOR_SWIFT;
- (BOOL)scanUTF8String:(NSString *_Nullable *_Nullable)outString error:(NSError *_Nullable *_Nullable)error NS_REFINED_FOR_SWIFT;
- (BOOL)scanIA5String:(NSString *_Nullable *_Nullable)outString error:(NSError *_Nullable *_Nullable)error NS_REFINED_FOR_SWIFT;

@property (readonly) BOOL isAtEnd;

@end
