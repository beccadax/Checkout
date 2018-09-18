//
//  AppReceiptViewController.swift
//  Checkout Viewer
//
//  Created by Brent Royal-Gordon on 11/6/17.
//  Copyright © 2017 Architechies. All rights reserved.
//

import Cocoa

class AppReceiptViewController: NSViewController, RepresentationViewController {
    var desiredRepresentationKeyPath: PartialKeyPath<ReceiptRepresentations> {
        return \.appReceipt
    }
    
    override var representedObject: Any? {
        didSet { update() }
    }
    
    @IBOutlet var dataSource: MirrorDataSource? {
        didSet { update() }
    }
    
    func update() {
        dataSource?.root = representedObject.map { (label: nil, value: $0) }
    }
}

class MirrorDataSource: NSObject, NSOutlineViewDataSource {
    private func indices(from item: Any?) -> [AnyIndex] {
        return item as! [AnyIndex]? ?? []
    }
    
    @IBOutlet var outlineView: NSOutlineView?
    var root: Mirror.Child? {
        didSet { outlineView?.reloadData() }
    }
    
    func child(at indexPath: [AnyIndex]) -> Mirror.Child {
        return indexPath.reduce(root!) { parent, index in
            return children(of: parent)[index]
        }
    }
    
    func children(of parent: Mirror.Child) -> Mirror.Children {
        let realValue = deSwiftValueIfNeeded(parent.value)
        return Mirror(reflecting: realValue).children
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        let indices = self.indices(from: item)
        return !children(of: child(at: indices)).isEmpty
    }
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if root == nil {
            return 0
        }
        
        // XXX Need to figure out how we're handling errors!
        let indices = self.indices(from: item)
        let parent = child(at: indices)
        let children = self.children(of: parent)
        return Int(children.count)
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        let indices = self.indices(from: item)
        let children = self.children(of: child(at: indices))
        
        return indices + [ children.index(children.startIndex, offsetBy: Int64(index)) ]
    }
    
    func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
        let indices = self.indices(from: item)
        let child = self.child(at: indices)
        
        switch tableColumn?.identifier {
        case .label?:
            if let label = child.label {
                return label
            }
            
            // Derive an index to use instead.
            guard !indices.isEmpty else {
                return "(Root)"
            }
            
            let parentIndices = Array(indices.dropLast())
            let siblings = children(of: self.child(at: parentIndices))
            return String(siblings.distance(from: siblings.startIndex, to: indices.last!))
            
        case .value?:
            return Mirror(reflecting: child.value).description
            
        default:
            fatalError()
        }
    }
}
