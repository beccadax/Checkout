//
//  Fallible.swift
//  Checkout Viewer
//
//  Created by Brent Royal-Gordon on 11/6/17.
//  Copyright © 2017 Architechies. All rights reserved.
//

import Foundation

enum Fallible<Value>: AnyFallible {
    case success(Value)
    case failure(Error)
    
    init(_ body: @autoclosure () throws -> Value) {
        do {
            self = .success(try body())
        }
        catch {
            self = .failure(error)
        }
    }
    
    var value: Value? {
        get {
            guard case .success(let value) = self else { return nil }
            return value
        }
    }
    
    var error: Error? {
        get {
            guard case .failure(let error) = self else { return nil }
            return error
        }
    }
    
    var _anyValue: Any? {
        return value
    }
}

protocol AnyFallible {
    var _anyValue: Any? { get }
    var error: Error? { get }
}

extension Fallible where Value == Any {
    init(erased anyFallible: AnyFallible) {
        switch (anyFallible._anyValue, anyFallible.error) {
        case (let value?, nil):
            self = .success(value)
        case (nil, let error?):
            self = .failure(error)
        default:
            fatalError("Invalid AnyFallible conformance")
        }
    }
}
