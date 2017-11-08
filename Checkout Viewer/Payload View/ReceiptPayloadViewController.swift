//
//  ReceiptPayloadViewController.swift
//  Checkout Viewer
//
//  Created by Brent Royal-Gordon on 11/6/17.
//  Copyright © 2017 Architechies. All rights reserved.
//

import Cocoa
import Checkout

class ReceiptPayloadViewController: NSViewController, RepresentationViewController {
    var desiredRepresentationKeyPath: PartialKeyPath<ReceiptRepresentations> {
        return \.receiptPayload
    }
    
    override var representedObject: Any? {
        didSet { update() }
    }
    
    @IBOutlet var dataSource: ReceiptPayloadDataSource? {
        didSet { update() }
    }
    
    func update() {
        guard case .success(let payload)? = (representedObject as! Fallible<ReceiptPayload>?) else {
            dataSource?.root = nil
            return
        }
        
        dataSource?.root = PayloadOutline(payload)
    }
}
