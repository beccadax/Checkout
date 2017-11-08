//
//  Fallible.swift
//  Checkout Viewer
//
//  Created by Brent Royal-Gordon on 11/6/17.
//  Copyright © 2017 Architechies. All rights reserved.
//

import Foundation

enum Fallible<Value> {
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
}
