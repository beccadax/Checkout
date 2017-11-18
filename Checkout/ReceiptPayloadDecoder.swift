//
//  PayloadDecoder.swift
//  Checkout
//
//  Created by Brent Royal-Gordon on 11/5/17.
//  Copyright © 2017 Architechies. All rights reserved.
//

import Foundation

class ReceiptPayloadDecoder {
    public init() {}
    
    public var userInfo: [CodingUserInfoKey: Any] = [:]
    
    public func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        let decoder = _Decoder(attributes: [ReceiptPayload.Attribute(type: 0, version: 1, value: data)], codingPath: [], userInfo: userInfo)
        return try type.init(from: decoder)
    }
    
    fileprivate class _Decoder: Decoder {
        let attributes: [ReceiptPayload.Attribute]
        let codingPath: [CodingKey]
        let userInfo: [CodingUserInfoKey : Any]
        
        init(attributes: [ReceiptPayload.Attribute], codingPath: [CodingKey], userInfo: [CodingUserInfoKey : Any]) {
            self.attributes = attributes
            self.codingPath = codingPath
            self.userInfo = userInfo
        }
        
        func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
            guard let attribute = attributes.first else {
                throw DecodingError.valueNotFound(Any.self, .init(codingPath: codingPath, debugDescription: "The payload did not contain any values at coding path \(codingPath)"))
            }
            
            let payload = try ReceiptPayload(data: attribute.value)
            return KeyedDecodingContainer(KeyedContainer(decoder: self, payload: payload))
        }
        
        func unkeyedContainer() throws -> UnkeyedDecodingContainer {
            return UnkeyedContainer(decoder: self, attributes: attributes, currentIndex: 0)
        }
        
        func singleValueContainer() throws -> SingleValueDecodingContainer {
            return SingleValueContainer(decoder: self, attributes: attributes)
        }
        
        struct SingleValueContainer: SingleValueDecodingContainer {
            let decoder: Decoder
            let attributes: [ReceiptPayload.Attribute]
            
            var codingPath: [CodingKey] {
                return decoder.codingPath
            }
            
            func decodeNil() -> Bool {
                return attributes.isEmpty
            }
            
            private func _decode<T>(_ type: T.Type) throws -> T where T : Decodable {
                func attribute() throws -> ReceiptPayload.Attribute {
                    guard let attribute = attributes.first else {
                        throw DecodingError.valueNotFound(type, .init(codingPath: codingPath, debugDescription: "The payload did not contain any values at coding path \(codingPath)"))
                    }
                    return attribute
                }
                
                switch type {
                case is Data.Type:
                    return try attribute().value as! T
                    
                case is String.Type:
                    let attr = try attribute()
                    do {
                        return try attr.utf8StringValue() as! T
                    }
                    catch {
                        if let ascii = try? attr.ia5StringValue() {
                            return ascii as! T
                        }
                        throw error
                    }
                    
                case is Date.Type:
                    return try attribute().dateValue() as! T
                    
                case is Int.Type:
                    return try attribute().intValue() as! T
                    
                default:
                    return try type.init(from: _Decoder(attributes: attributes, codingPath: codingPath, userInfo: decoder.userInfo))
                    
//                    throw DecodingError.typeMismatch(type, .init(codingPath: codingPath, debugDescription: "The payload contained a type, \(type), which could not be decoded."))
                }
            }
            
            func decode(_ type: Bool.Type) throws -> Bool {
                return try _decode(type)
            }
            
            func decode(_ type: Int.Type) throws -> Int {
                return try _decode(type)
            }
            
            func decode(_ type: Int8.Type) throws -> Int8 {
                return try _decode(type)
            }
            
            func decode(_ type: Int16.Type) throws -> Int16 {
                return try _decode(type)
            }
            
            func decode(_ type: Int32.Type) throws -> Int32 {
                return try _decode(type)
            }
            
            func decode(_ type: Int64.Type) throws -> Int64 {
                return try _decode(type)
            }
            
            func decode(_ type: UInt.Type) throws -> UInt {
                return try _decode(type)
            }
            
            func decode(_ type: UInt8.Type) throws -> UInt8 {
                return try _decode(type)
            }
            
            func decode(_ type: UInt16.Type) throws -> UInt16 {
                return try _decode(type)
            }
            
            func decode(_ type: UInt32.Type) throws -> UInt32 {
                return try _decode(type)
            }
            
            func decode(_ type: UInt64.Type) throws -> UInt64 {
                return try _decode(type)
            }
            
            func decode(_ type: Float.Type) throws -> Float {
                return try _decode(type)
            }
            
            func decode(_ type: Double.Type) throws -> Double {
                return try _decode(type)
            }
            
            func decode(_ type: String.Type) throws -> String {
                return try _decode(type)
            }
            
            func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
                return try _decode(type)
            }
        }
        
        struct UnkeyedContainer: UnkeyedDecodingContainer {
            let decoder: Decoder
            let attributes: [ReceiptPayload.Attribute]
            
            var codingPath: [CodingKey] {
                return decoder.codingPath
            }
            
            var count: Int? {
                return attributes.count
            }
            
            var isAtEnd: Bool {
                return currentIndex == attributes.endIndex
            }
            
            var currentIndex = 0
            
            mutating func makeNextChildDecoder() -> _Decoder {
                guard !isAtEnd else {
                    return _Decoder(attributes: [], codingPath: codingPath, userInfo: decoder.userInfo)
                }
                
                let currentAttribute = attributes[currentIndex]
                defer { currentIndex += 1 }
                return _Decoder(attributes: [currentAttribute], codingPath: codingPath, userInfo: decoder.userInfo)
            }

            mutating func decodeNil() throws -> Bool {
                return try makeNextChildDecoder().singleValueContainer().decodeNil()
            }
            
            mutating func decode(_ type: Bool.Type) throws -> Bool {
                return try makeNextChildDecoder().singleValueContainer().decode(type)
            }
            
            mutating func decode(_ type: Int.Type) throws -> Int {
                return try makeNextChildDecoder().singleValueContainer().decode(type)
            }
            
            mutating func decode(_ type: Int8.Type) throws -> Int8 {
                return try makeNextChildDecoder().singleValueContainer().decode(type)
            }
            
            mutating func decode(_ type: Int16.Type) throws -> Int16 {
                return try makeNextChildDecoder().singleValueContainer().decode(type)
            }
            
            mutating func decode(_ type: Int32.Type) throws -> Int32 {
                return try makeNextChildDecoder().singleValueContainer().decode(type)
            }
            
            mutating func decode(_ type: Int64.Type) throws -> Int64 {
                return try makeNextChildDecoder().singleValueContainer().decode(type)
            }
            
            mutating func decode(_ type: UInt.Type) throws -> UInt {
                return try makeNextChildDecoder().singleValueContainer().decode(type)
            }
            
            mutating func decode(_ type: UInt8.Type) throws -> UInt8 {
                return try makeNextChildDecoder().singleValueContainer().decode(type)
            }
            
            mutating func decode(_ type: UInt16.Type) throws -> UInt16 {
                return try makeNextChildDecoder().singleValueContainer().decode(type)
            }
            
            mutating func decode(_ type: UInt32.Type) throws -> UInt32 {
                return try makeNextChildDecoder().singleValueContainer().decode(type)
            }
            
            mutating func decode(_ type: UInt64.Type) throws -> UInt64 {
                return try makeNextChildDecoder().singleValueContainer().decode(type)
            }
            
            mutating func decode(_ type: Float.Type) throws -> Float {
                return try makeNextChildDecoder().singleValueContainer().decode(type)
            }
            
            mutating func decode(_ type: Double.Type) throws -> Double {
                return try makeNextChildDecoder().singleValueContainer().decode(type)
            }
            
            mutating func decode(_ type: String.Type) throws -> String {
                return try makeNextChildDecoder().singleValueContainer().decode(type)
            }
            
            mutating func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
                return try makeNextChildDecoder().singleValueContainer().decode(type)
            }
            
            mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
                return try makeNextChildDecoder().container(keyedBy: type)
            }
            
            mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
                fatalError("PayloadDecoder doesn't support nesting unkeyed containers inside one another")
            }
            
            mutating func superDecoder() throws -> Decoder {
                return makeNextChildDecoder()
            }
        }
        
        struct KeyedContainer<CodingKeys: CodingKey>: KeyedDecodingContainerProtocol {
            typealias Key = CodingKeys
            
            let decoder: Decoder
            let payload: ReceiptPayload
            
            var codingPath: [CodingKey] {
                return decoder.codingPath
            }
            
            var allKeys: [CodingKeys] {
                return payload.attributes.map { $0.type }.flatMap { CodingKeys(intValue: $0) }
            }
            
            func attributes(for key: CodingKeys) -> [ReceiptPayload.Attribute] {
                precondition(key.intValue != nil, "PayloadDecoder can only be used with keys that have intValues")
                return payload.attributes.filter { $0.type == key.intValue }
            }
            
            func contains(_ key: CodingKeys) -> Bool {
                return !attributes(for: key).isEmpty
            }
            
            func makeChildDecoder(forKey key: CodingKeys) -> _Decoder {
                let attributes = self.attributes(for: key)
                return _Decoder(attributes: attributes, codingPath: codingPath + [key], userInfo: decoder.userInfo)
            }
            
            func decodeNil(forKey key: CodingKeys) throws -> Bool {
                return try makeChildDecoder(forKey: key).singleValueContainer().decodeNil()
            }
            
            func decode(_ type: Bool.Type, forKey key: CodingKeys) throws -> Bool {
                return try makeChildDecoder(forKey: key).singleValueContainer().decode(type)
            }
            
            func decode(_ type: Int.Type, forKey key: CodingKeys) throws -> Int {
                return try makeChildDecoder(forKey: key).singleValueContainer().decode(type)
            }
            
            func decode(_ type: Int8.Type, forKey key: CodingKeys) throws -> Int8 {
                return try makeChildDecoder(forKey: key).singleValueContainer().decode(type)
            }
            
            func decode(_ type: Int16.Type, forKey key: CodingKeys) throws -> Int16 {
                return try makeChildDecoder(forKey: key).singleValueContainer().decode(type)
            }
            
            func decode(_ type: Int32.Type, forKey key: CodingKeys) throws -> Int32 {
                return try makeChildDecoder(forKey: key).singleValueContainer().decode(type)
            }
            
            func decode(_ type: Int64.Type, forKey key: CodingKeys) throws -> Int64 {
                return try makeChildDecoder(forKey: key).singleValueContainer().decode(type)
            }
            
            func decode(_ type: UInt.Type, forKey key: CodingKeys) throws -> UInt {
                return try makeChildDecoder(forKey: key).singleValueContainer().decode(type)
            }
            
            func decode(_ type: UInt8.Type, forKey key: CodingKeys) throws -> UInt8 {
                return try makeChildDecoder(forKey: key).singleValueContainer().decode(type)
            }
            
            func decode(_ type: UInt16.Type, forKey key: CodingKeys) throws -> UInt16 {
                return try makeChildDecoder(forKey: key).singleValueContainer().decode(type)
            }
            
            func decode(_ type: UInt32.Type, forKey key: CodingKeys) throws -> UInt32 {
                return try makeChildDecoder(forKey: key).singleValueContainer().decode(type)
            }
            
            func decode(_ type: UInt64.Type, forKey key: CodingKeys) throws -> UInt64 {
                return try makeChildDecoder(forKey: key).singleValueContainer().decode(type)
            }
            
            func decode(_ type: Float.Type, forKey key: CodingKeys) throws -> Float {
                return try makeChildDecoder(forKey: key).singleValueContainer().decode(type)
            }
            
            func decode(_ type: Double.Type, forKey key: CodingKeys) throws -> Double {
                return try makeChildDecoder(forKey: key).singleValueContainer().decode(type)
            }
            
            func decode(_ type: String.Type, forKey key: CodingKeys) throws -> String {
                return try makeChildDecoder(forKey: key).singleValueContainer().decode(type)
            }
            
            func decode<T>(_ type: T.Type, forKey key: CodingKeys) throws -> T where T : Decodable {
                return try makeChildDecoder(forKey: key).singleValueContainer().decode(type)
            }
            
            func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: CodingKeys) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
                return try makeChildDecoder(forKey: key).container(keyedBy: type)
            }
            
            func nestedUnkeyedContainer(forKey key: CodingKeys) throws -> UnkeyedDecodingContainer {
                return try makeChildDecoder(forKey: key).unkeyedContainer()
            }
            
            func superDecoder() throws -> Decoder {
                preconditionFailure("PayloadDecoder does not support superDecoder()")
            }
            
            func superDecoder(forKey key: CodingKeys) throws -> Decoder {
                return makeChildDecoder(forKey: key)
            }
        }
    }
}
