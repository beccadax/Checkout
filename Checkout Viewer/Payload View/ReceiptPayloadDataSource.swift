//
//  ReceiptPayloadDataSource.swift
//  Checkout Viewer
//
//  Created by Brent Royal-Gordon on 11/7/17.
//  Copyright © 2017 Architechies. All rights reserved.
//

import AppKit

class ReceiptPayloadDataSource: NSObject, NSOutlineViewDataSource {
    @IBOutlet var outlineView: NSOutlineView?
    
    var root: PayloadOutline? {
        didSet { outlineView?.reloadData() }
    }
    
    func outline(for item: Any?) -> PayloadOutline? {
        guard let attribute = item as? PayloadOutline.Attribute else {
            // No, this is the top-level payload.
            return root
        }
        
        return attribute.value.payload
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return outline(for: item) != nil
    }
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        return outline(for: item)?.attributes.count ?? 0
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        return outline(for: item)!.attributes[index]
    }
    
    func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
        return item as! PayloadOutline.Attribute
    }
}
