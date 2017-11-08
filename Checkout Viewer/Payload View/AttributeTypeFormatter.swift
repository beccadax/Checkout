//
//  AttributeTypeFormatter.swift
//  Checkout Viewer
//
//  Created by Brent Royal-Gordon on 11/7/17.
//  Copyright © 2017 Architechies. All rights reserved.
//

import AppKit
import Checkout

class AttributeTypeFormatter: Formatter {
    @IBInspectable var secondaryColor = NSColor.disabledControlTextColor
    
    override func string(for obj: Any?) -> String? {
        return obj.flatMap { attributedString(for: $0) }?.string
    }
    
    override func attributedString(for obj: Any, withDefaultAttributes attrs: [NSAttributedStringKey: Any]? = nil) -> NSAttributedString? {
        let attrs = attrs ?? [:]
        let grayAttrs = attrs.merging([.foregroundColor: secondaryColor], uniquingKeysWith: { _, new in new })
        
        guard let type = obj as? Int else {
            return NSAttributedString(string: "Invalid", attributes: grayAttrs)
        }
        
        guard let attributeName = payloadReceiptAttributeTypeName(for: type) else {
            return NSAttributedString(string: "Unknown – \(type)", attributes: grayAttrs)
        }
        
        return NSAttributedString(string: attributeName, attributes: attrs)
    }
}
