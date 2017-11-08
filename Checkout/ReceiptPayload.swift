//
//  Payload.swift
//  Checkout
//
//  Created by Brent Royal-Gordon on 11/5/17.
//  Copyright © 2017 Architechies. All rights reserved.
//

import Foundation

private let dateFormatter: DateFormatter = {
    let f = DateFormatter()
    f.locale = Locale(identifier: "en_US_POSIX")
    f.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
    f.timeZone = TimeZone(secondsFromGMT: 0)
    return f
}()

public struct ReceiptPayload {
    public struct Attribute {
        public let type: Int
        public let version: Int
        public let value: Data
        
        public func intValue() throws -> Int {
            return try _ASN1Scanner(data: value).scanInteger()
        }
        
        public func utf8StringValue() throws -> String {
            return try _ASN1Scanner(data: value).scanUTF8String()
        }
        
        public func ia5StringValue() throws -> String {
            return try _ASN1Scanner(data: value).scanIA5String()
        }
        
        public func dateValue() throws -> Date {
            let stringValue = try ia5StringValue()
            guard let date = dateFormatter.date(from: stringValue) else {
                throw CheckoutError.invalidDate
            }
            return date
        }
        
        public func payloadValue() throws -> ReceiptPayload {
            return try ReceiptPayload(data: value)
        }
    }
    
    public var attributes: [Attribute]
    
    public init(data: Data) throws {
        let scanner = _ASN1Scanner(data: data)
        
        // Scan the whole set of attributes
        attributes = try scanner.scanObject(with: .set) { scanner in
            var attributes: [Attribute] = []
            while !scanner.isAtEnd {
                let attribute = try scanner.scanObject(with: .sequence) { scanner -> Attribute in
                    let type = try scanner.scanInteger()
                    let version = try scanner.scanInteger()
                    let value = try scanner.scanOctetString()
                    
                    return Attribute(type: type, version: version, value: value)
                }
                attributes.append(attribute)
            }
            return attributes
        }
    }
}
