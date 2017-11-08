//
//  PayloadOutline.swift
//  Checkout Viewer
//
//  Created by Brent Royal-Gordon on 11/7/17.
//  Copyright © 2017 Architechies. All rights reserved.
//

import Foundation
import Checkout

class PayloadOutline: NSObject {
    let attributes: [Attribute]
    
    init(attributes: [Attribute]) {
        self.attributes = attributes
    }
    
    convenience init(_ payload: ReceiptPayload) {
        self.init(attributes: payload.attributes.map(Attribute.init(_:)))
    }
    
    class Attribute: NSObject {
        @objc let type: Int
        @objc let version: Int
        @objc let value: Value
        
        init(type: Int, version: Int, value: Value) {
            self.type = type
            self.version = version
            self.value = value
        }
        
        convenience init(_ attribute: ReceiptPayload.Attribute) {
            self.init(type: attribute.type, version: attribute.version, value: Value(attribute))
        }
    }
    
    class Value: NSObject, NSCopying {
        @objc let raw: Data
        
        @objc let int: NSNumber?
        @objc let date: Date?
        @objc let ia5String: String?
        @objc let utf8String: String?
        @objc let payload: PayloadOutline?

        init(_ attribute: ReceiptPayload.Attribute) {
            raw = attribute.value
            int = (try? attribute.intValue()).map { $0 as NSNumber }
            date = try? attribute.dateValue()
            ia5String = try? attribute.ia5StringValue()
            utf8String = try? attribute.utf8StringValue()
            payload = (try? attribute.payloadValue()).map(PayloadOutline.init(_:))
        }
        
        func copy(with zone: NSZone? = nil) -> Any {
            return self
        }
    }
}
