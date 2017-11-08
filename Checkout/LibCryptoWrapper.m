//
//  LibCryptoWrapper.m
//  Checkout
//
//  Created by Brent Royal-Gordon on 11/5/17.
//  Copyright © 2017 Architechies. All rights reserved.
//

#import "LibCryptoWrapper.h"
#import <openssl/x509.h>
#import <openssl/pkcs7.h>
#import <openssl/err.h>

NSErrorDomain const OpenSSLErrorDomain = @"Checkout.OpenSSLErrorDomain";
NSErrorDomain const OpenSSLWrapperErrorDomain = @"Checkout.OpenSSLWrapperErrorDomain";

NSErrorUserInfoKey const OpenSSLObjectTagKey = @"Checkout.OpenSSLObjectTagKey";

static void populateErrorFromOpenSSL(NSError ** error) {
    if (!error) {
        while (ERR_get_error() != 0) /* do nothing */;
        return;
    }
    
    ERR_load_crypto_strings();
    
    *error = nil;
    unsigned long code;
    
    while ((code = ERR_get_error()) != 0) {
        NSDictionary<NSErrorUserInfoKey, id> * userInfo = nil;
        if (*error) {
            userInfo = @{ NSUnderlyingErrorKey: *error };
        }
        
        *error = [NSError errorWithDomain:OpenSSLErrorDomain code:code userInfo:userInfo];
    }
}

@implementation _BIO {
    @public
    BIO * _bio;
}

+ (void)load {
    // Set up some error stuff.
    [NSError setUserInfoValueProviderForDomain:OpenSSLErrorDomain provider:^id _Nullable(NSError * _Nonnull err, NSErrorUserInfoKey  _Nonnull userInfoKey) {
        if ([userInfoKey isEqualToString:NSLocalizedDescriptionKey]) {
            const char * library = ERR_lib_error_string(err.code);
            const char * reason = ERR_reason_error_string(err.code);
            const char * function = ERR_func_error_string(err.code);
            
            if (library && reason && function) {
                return [NSString stringWithFormat:@"The App Store receipt could not be read due to %s in %s (%s).", reason, library, function];
            }
            else {
                return [NSString stringWithFormat:NSLocalizedString(@"The App Store receipt could not be read. (OpenSSL code %d)", @""), err.code];
            }
        }
        
        return nil;
    }];
    
    [NSError setUserInfoValueProviderForDomain:OpenSSLWrapperErrorDomain provider:^id _Nullable(NSError * _Nonnull err, NSErrorUserInfoKey  _Nonnull userInfoKey) {
        if ([userInfoKey isEqualToString:NSLocalizedDescriptionKey]) {
            switch ((OpenSSLWrapperErrorCode)err.code) {
                case OpenSSLWrapperErrorPartiallyScannedObject:
                    return NSLocalizedString(@"The application did not fully process an object in the App Store receipt.", @"");
                    
                case OpenSSLWrapperErrorWrongObjectTag:
                    return NSLocalizedString(@"The application encountered an unexpected object in the App Store receipt.", @"");
            }
        }
        
        return nil;
    }];
}

- (instancetype)initWithData:(NSData *)data error:(NSError *__autoreleasing *)error {
    if (self = [super init]) {
        OPENSSL_init();
        
        _bio = BIO_new(BIO_s_mem());
        if (!_bio) {
            populateErrorFromOpenSSL(error);
            return nil;
        }
        
        int result = BIO_write(_bio, data.bytes, (int)data.length); 
        if (result < 0) {
            populateErrorFromOpenSSL(error);
            return nil;
        }
    }
    return self;
}

- (BOOL)isAtEnd {
    return BIO_eof(_bio);
}

- (NSInteger)offsetInFile {
    return BIO_tell(_bio);
}

- (NSData*)readDataOfLength:(NSInteger)maxLength error:(NSError **)error {
    NSMutableData * data = [[NSMutableData alloc] initWithLength:maxLength];
    
    int actualLength = BIO_read(_bio, data.mutableBytes, (int)data.length);
    if (actualLength < 0) {
        populateErrorFromOpenSSL(error);
        return nil;
    }
    
    return [data subdataWithRange:NSMakeRange(0, actualLength)];
}

@end

@implementation _X509 {
@public
    X509 * _cert;
}

- (instancetype)initWithData:(_BIO *)bio error:(NSError *__autoreleasing *)error {
    if ((self = [super init])) {
        _cert = d2i_X509_bio(bio->_bio, NULL);
        if (!_cert) {
            populateErrorFromOpenSSL(error);
            return nil;
        }
    }
    return self;
}

@end

@implementation _X509Store {
@public
    X509_STORE * _store;
}

- (instancetype)init {
    if (self = [super init]) {
        _store = X509_STORE_new();
    }
    return self;
}

- (BOOL)addCertificate:(_X509*)cert error:(NSError *__autoreleasing *)error {
    if (X509_STORE_add_cert(_store, cert->_cert) == 0) {
        populateErrorFromOpenSSL(error);
        return NO;
    }
    else {
        return YES;
    }
}

- (void)dealloc {
    X509_STORE_free(_store);
}

@end

@interface _PKCS7Signed ()

- (instancetype)initWithPKCS7Signed:(PKCS7_SIGNED*)signedContainer parent:(id)parent;

@end

@implementation _PKCS7 {
    @public
    PKCS7 * _container;
    id _parent;
}

- (instancetype)initWithPKCS7:(PKCS7*)container parent:(id)parent {
    if ((self = [super init])) {
        _container = container;
        _parent = parent;
    }
    return self;
}

- (instancetype)initWithData:(_BIO*)bio error:(NSError**)error {
    PKCS7 * container = d2i_PKCS7_bio(bio->_bio, NULL);
    if (!container) {
        populateErrorFromOpenSSL(error);
        return nil;
    }
    
    return [self initWithPKCS7:container parent:nil];
}

- (BOOL)getSigned:(_PKCS7Signed**)signed7 error:(NSError**)error {
    switch (OBJ_obj2nid(_container->type)) {
        case NID_undef:
            populateErrorFromOpenSSL(error);
            return NO;
        case NID_pkcs7_signed:
            if (signed7) {
                *signed7 = [[_PKCS7Signed alloc] initWithPKCS7Signed:_container->d.sign parent: self];
            }
            return YES;
        default:
            if (signed7) {
                *signed7 = nil;
            }
            return YES;
    }
}

- (BOOL)getData:(NSData**)data error:(NSError**)error {
    switch (OBJ_obj2nid(_container->type)) {
        case NID_undef:
            populateErrorFromOpenSSL(error);
            return NO;
        case NID_pkcs7_data:
            if (data) {
                *data = [[NSData alloc] initWithBytes:_container->d.data->data length:_container->d.data->length];
            }
            return YES;
        default:
            if (data) {
                *data = nil;
            }
            return YES;
    }
}

- (BOOL)verifyWithCertificates:(_X509Store*)certificateStore error:(NSError**)error {
    OpenSSL_add_all_digests();
    
    if (PKCS7_verify(_container, NULL, certificateStore->_store, NULL, NULL, 0) == 1) {
        return YES;
    }
    else {
        populateErrorFromOpenSSL(error);
        return NO;
    }
}

- (void)dealloc {
    if (!_parent) {
        PKCS7_free(_container);
    }
}

@end

@implementation _PKCS7Signed {
    PKCS7_SIGNED * _signedContainer;
    id _parent;
}

- (instancetype)initWithPKCS7Signed:(PKCS7_SIGNED*)signedContainer parent:(id)parent {
    if (self = [super init]) {
        _signedContainer = signedContainer;
        _parent = parent;
    }
    return self;
}

- (_PKCS7*)contentsWithError:(NSError**)error; {
    return [[_PKCS7 alloc] initWithPKCS7:_signedContainer->contents parent:self];
}

@end

@implementation _ASN1Scanner {
    NSData * _data;
    const unsigned char *_next;
    const unsigned char *_end;
}

- (instancetype)initWithData:(NSData *)data {
    if ((self = [super init])) {
        _data = [data copy];
        _next = data.bytes;
        _end = data.bytes + data.length;
    }
    return self;
}

- (BOOL)isAtEnd {
    return _next == _end;
}

- (BOOL)scanObjectWithTag:(_ASN1ScannerObjectTag)tag scanBlock:(BOOL(^_Nonnull)(_ASN1Scanner*_Nonnull, NSError *_Nullable *_Nullable))scanBlock error:(NSError *_Nullable *_Nullable)error {
    _ASN1ScannerObjectTag outTag;
    long length = 0;
    int xclass = 0;
    
    // XXX I'm not sure this is the right error check, but it looks like it
    // from the source.
    if (ASN1_get_object(&_next, &length, &outTag, &xclass, _end - _next) & 0x80) {
        populateErrorFromOpenSSL(error);
        return NO;
    }
    
    if (tag != outTag) {
        if (error) {
            *error = [NSError errorWithDomain:OpenSSLWrapperErrorDomain code:OpenSSLWrapperErrorWrongObjectTag userInfo:@{ OpenSSLObjectTagKey: @(outTag) }];
            return NO;
        }
    }
    
    NSData * subdata = [[NSData alloc] initWithBytes:_next length:length];
    _ASN1Scanner * subScanner = [[_ASN1Scanner alloc] initWithData:subdata];
    
    BOOL ok = scanBlock(subScanner, error);
    
    if (ok && !subScanner.isAtEnd) {
        if (error) {
            *error = [NSError errorWithDomain:OpenSSLWrapperErrorDomain code:OpenSSLWrapperErrorPartiallyScannedObject userInfo:@{}];
        }
        return NO;
    }
    else {
        _next += length;
    }
    
    return ok;
}

- (NSInteger)scanRawInteger {
    ASN1_INTEGER * integer;
    
    integer = c2i_ASN1_INTEGER(NULL, &_next, _end - _next);
    long value = ASN1_INTEGER_get(integer);
    ASN1_INTEGER_free(integer);
    
    return value;
}

- (NSData*)scanRawData {
    NSData * data = [[NSData alloc] initWithBytes:_next length:_end - _next];
    _next = _end;
    return data;
}

- (BOOL)scanInteger:(NSInteger *)outInteger error:(NSError *__autoreleasing  _Nullable *)error {
    return [self scanObjectWithTag:_ASN1ScannerObjectTagInteger scanBlock:^BOOL(_ASN1Scanner * scanner, NSError ** error) {
        NSInteger value = [scanner scanRawInteger];
        if (outInteger) {
            *outInteger = value;
        }
        return YES;
    } error:error];
}

- (BOOL)scanData:(__autoreleasing NSData **)outData withTag:(_ASN1ScannerObjectTag)tag error:(NSError**)error {
    return [self scanObjectWithTag:tag scanBlock:^BOOL(_ASN1Scanner * scanner, NSError **error) {
        NSData * data = [scanner scanRawData];
        if (outData) {
            *outData = data;
        }
        return YES;
    } error:error];
}

- (BOOL)scanOctetString:(NSData *__autoreleasing  _Nullable *)outOctets error:(NSError *__autoreleasing  _Nullable *)error {
    return [self scanData:outOctets withTag:_ASN1ScannerObjectTagOctetString error:error];
}

- (BOOL)scanUTF8String:(NSString *__autoreleasing  _Nullable *)outString error:(NSError *__autoreleasing  _Nullable *)error {
    NSData * data = nil;
    if (![self scanData:&data withTag:_ASN1ScannerObjectTagUTF8String error:error]) {
        return NO;
    }
    if (outString) {
        *outString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    return YES;
}

- (BOOL)scanIA5String:(NSString *__autoreleasing  _Nullable *)outString error:(NSError *__autoreleasing  _Nullable *)error {
    NSData * data = nil;
    if (![self scanData:&data withTag:_ASN1ScannerObjectTagIA5String error:error]) {
        return NO;
    }
    if (outString) {
        *outString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    }
    return YES;
}

@end

