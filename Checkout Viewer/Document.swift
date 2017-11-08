//
//  Document.swift
//  Checkout Viewer
//
//  Created by Brent Royal-Gordon on 11/6/17.
//  Copyright © 2017 Architechies. All rights reserved.
//

import Cocoa
import Checkout

class Document: NSDocument {
    override class var autosavesInPlace: Bool {
        return true
    }

    override func makeWindowControllers() {
        // Returns the Storyboard that contains your Document window.
        let storyboard = NSStoryboard(name: .main, bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: .documentWindowController) as! NSWindowController
        self.addWindowController(windowController)
        
        updateRepresentedObject()
    }
    
    var representedObject: ReceiptRepresentations? {
        didSet { updateRepresentedObject() }
    }
    
    func updateRepresentedObject() {
        for controller in windowControllers {
            controller.contentViewController!.representedObject = representedObject
        }
    }
    
    override func writableTypes(for saveOperation: NSDocument.SaveOperationType) -> [String] {
        return []
    }
    
    override func read(from data: Data, ofType typeName: String) throws {
        representedObject = ReceiptRepresentations(from: data)
    }

    override func data(ofType typeName: String) throws -> Data {
        throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
    }
}
