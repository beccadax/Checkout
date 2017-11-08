//
//  LibCryptoWrapper.swift
//  Checkout
//
//  Created by Brent Royal-Gordon on 11/5/17.
//  Copyright © 2017 Architechies. All rights reserved.
//

import Foundation

extension _PKCS7 {
    func signed() throws -> _PKCS7Signed? {
        var ret: _PKCS7Signed?
        try __getSigned(&ret)
        return ret
    }
    
    func data() throws -> Data? {
        var ret: NSData?
        try __getData(&ret)
        return ret as Data?
    }
}

extension _ASN1Scanner {
    func scanObject<T>(with tag: _ASN1ScannerObjectTag, using scanBlock: (_ASN1Scanner) throws -> T) throws -> T {
        return try withoutActuallyEscaping(scanBlock) { scanBlock in
            var value: T!
            try self.__scanObject(with: tag, scanBlock: { (scanner, outError) in 
                do {
                    value = try scanBlock(scanner)
                    return true
                }
                catch {
                    outError?.pointee = error as NSError
                    return false
                }
            })
            return value
        }
    }
    
    func scanInteger() throws -> Int {
        var value: Int = 0
        try __scanInteger(&value)
        return value
    }
    
    func scanOctetString() throws -> Data {
        var value: NSData?
        try __scanOctetString(&value)
        return value! as Data
    }
    
    func scanUTF8String() throws -> String {
        var value: NSString?
        try __scanUTF8String(&value)
        return value! as String
    }
    
    func scanIA5String() throws -> String {
        var value: NSString?
        try __scanIA5String(&value)
        return value! as String
    }
}
