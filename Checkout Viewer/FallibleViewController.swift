//
//  FallibleViewController.swift
//  Checkout Viewer
//
//  Created by Brent Royal-Gordon on 11/7/17.
//  Copyright © 2017 Architechies. All rights reserved.
//

import Cocoa

class FallibleViewController: NSViewController, RepresentationViewController {
    var failureViewController: NSViewController?
    var successViewController: (NSViewController & RepresentationViewController)? {
        didSet {
            successViewController?.view.wantsLayer = true
            update()
        }
    }
    
    var desiredRepresentationKeyPath: PartialKeyPath<ReceiptRepresentations> {
        return successViewController!.desiredRepresentationKeyPath
    }
    
    override var representedObject: Any? {
        didSet { update() }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.wantsLayer = true
        failureViewController?.view.wantsLayer = true
        
        update()
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case .failureViewController?:
            failureViewController = (segue.destinationController as! NSViewController)
            showingViewController = failureViewController
        default:
            fatalError()
        }
    }
    
    func update() {
        guard let representedObject = representedObject else {
            failureViewController?.representedObject = nil
            show(failureViewController)
            return
        }
        
        // WORKAROUND https://bugs.swift.org/browse/SR-3871
        let represented = representedObject as AnyObject
        let fallible = Fallible(erased: represented as! AnyFallible)
        
        switch fallible {
        case .success(let value):
            successViewController?.representedObject = value
            show(successViewController)
            
        case .failure(let error):
            failureViewController?.representedObject = error as NSError
            show(failureViewController)
        }
    }
    
    var showingViewController: NSViewController?
    
    func show(_ newController: NSViewController?) {
        guard
            let oldController = showingViewController,
            let newController = newController,
            oldController != newController
        else {
            return
        }
        
        showingViewController = newController
        
        let index = childViewControllers.index(of: oldController)!
        
        insertChildViewController(newController, at: index + 1)
        transition(from: oldController, to: newController, options: .slideDown) { 
            self.removeChildViewController(at: index)
        }
    }
}
