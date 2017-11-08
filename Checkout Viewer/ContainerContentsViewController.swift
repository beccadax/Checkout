//
//  ContainerContentsViewController.swift
//  Checkout Viewer
//
//  Created by Brent Royal-Gordon on 11/6/17.
//  Copyright © 2017 Architechies. All rights reserved.
//

import Cocoa

class ContainerContentsViewController: NSViewController, RepresentationViewController {
    var desiredRepresentationKeyPath: PartialKeyPath<ReceiptRepresentations> {
        return \.payloadData
    }
}
