//
//  _SwiftValue+any.swift
//  Checkout Viewer
//
//  Created by Brent Royal-Gordon on 11/18/17.
//  Copyright © 2017 Architechies. All rights reserved.
//

import Foundation

func deSwiftValueIfNeeded(_ value: Any) -> Any {
    var unboxed: Any?
    __getAny(value as AnyObject, &unboxed)
    return unboxed!
}
