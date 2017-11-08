//
//  AttributeValueFormatter.swift
//  Checkout Viewer
//
//  Created by Brent Royal-Gordon on 11/7/17.
//  Copyright © 2017 Architechies. All rights reserved.
//

import AppKit

class AttributeValueFormatter: Formatter {
    @IBInspectable var secondaryColor = NSColor.gray
    @IBInspectable var dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .medium
        return f
    }()
    
    override func string(for obj: Any?) -> String? {
        return obj.flatMap { attributedString(for: $0) }?.string
    }
    
    override func attributedString(for obj: Any, withDefaultAttributes attrs: [NSAttributedStringKey: Any]? = nil) -> NSAttributedString? {
        let attrs = attrs ?? [:]
        let grayAttrs = attrs.merging([.foregroundColor: secondaryColor], uniquingKeysWith: { _, new in new })
        
        guard let value = obj as? PayloadOutline.Value else {
            return NSAttributedString(string: "(Invalid)", attributes: attrs)
        }
        
        var tag: String
        var description: String
        
        switch (value.payload, value.int, value.date, value.ia5String, value.utf8String) {
        case (let payload?, _, _, _, _):
            tag = "Receipt Payload"
            description = "\(payload.attributes.count) attributes"

        case (nil, let int?, _, _, _):
            tag = "Integer"
            description = String(describing: int)
            
        case (nil, nil, let date?, _, _):
            tag = "Date"
            description = dateFormatter.string(from: date)
            
        case (nil, nil, nil, let ia5String?, _):
            tag = "IA5"
            description = ia5String
            
        case (nil, nil, nil, nil, let utf8String?):
            tag = "UTF8"
            description = utf8String
            
        case (nil, nil, nil, nil, nil):
            tag = value.raw.map { String($0, radix: 16) }.joined()
            description = "\(value.raw.count) bytes"
        }
        
        let text = NSMutableAttributedString(string: description, attributes: attrs)
        text.append(NSAttributedString(string: " – \(tag)", attributes: grayAttrs))
        return text
    }
}
