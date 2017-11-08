//
//  SignedContainer.swift
//  Checkout
//
//  Created by Brent Royal-Gordon on 11/5/17.
//  Copyright © 2017 Architechies. All rights reserved.
//

import Foundation

public struct SignedContainer {
    private let pkcs7: _PKCS7
    
    public init(data: Data) throws {
        pkcs7 = try _PKCS7(data: _BIO(data: data))
    }
    
    private func verifiedContents(with certStore: _X509Store) throws -> Data {
        guard let signed = try pkcs7.signed() else {
            throw CheckoutError.missingSignature
        }
        
        do {
            try pkcs7.verify(with: certStore)
        }
        catch {
            throw CheckoutError.invalidSignature(underlying: error)
        }
        
        guard let contents = try signed.contents().data() else {
            throw CheckoutError.missingContents
        }
        
        return contents
    } 
    
    public func verifiedContents(with certificates: [SigningCertificate] = [.apple]) throws -> Data {
        let store = _X509Store()
        for cert in certificates {
            try store.addCertificate(cert.x509)
        }
        return try verifiedContents(with: store)
    }
}

public struct SigningCertificate {
    public static let apple = try! SigningCertificate(contentsOf: Bundle(for: _X509.self).url(forResource: "Apple", withExtension: "cer")!)
    
    fileprivate let x509: _X509
    
    public init(contentsOf url: URL) throws {
        let data = try Data(contentsOf: url)
        try self.init(data: data)
    }
    
    public init(data: Data) throws {
        x509 = try _X509(data: _BIO(data: data))
    }
}
