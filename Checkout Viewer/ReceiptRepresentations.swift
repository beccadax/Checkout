//
//  ReceiptRepresentations.swift
//  Checkout Viewer
//
//  Created by Brent Royal-Gordon on 11/6/17.
//  Copyright © 2017 Architechies. All rights reserved.
//

import Foundation
import Checkout

class ReceiptRepresentations: NSObject {
    let signedContainer: Fallible<SignedContainer>
    let payloadData: Fallible<Data>
    let receiptPayload: Fallible<ReceiptPayload>
    let appReceipt: Fallible<AppReceipt>
    
    init(from data: Data) {
        signedContainer = Fallible(try SignedContainer(data: data))
        guard case .success(let signedContainer) = signedContainer else {
            payloadData = .failure(CheckoutViewerError.previousRepresentationFailed)
            receiptPayload = .failure(CheckoutViewerError.previousRepresentationFailed)
            appReceipt = .failure(CheckoutViewerError.previousRepresentationFailed)        
            super.init()
            return
        }
        
        payloadData = Fallible(try signedContainer.verifiedContents())
        guard case .success(let payloadData) = payloadData else {
            receiptPayload = .failure(CheckoutViewerError.previousRepresentationFailed)
            appReceipt = .failure(CheckoutViewerError.previousRepresentationFailed)        
            super.init()
            return
        }
        
        receiptPayload = Fallible(try ReceiptPayload(data: payloadData))
        guard case .success = receiptPayload else {
            appReceipt = .failure(CheckoutViewerError.previousRepresentationFailed)        
            super.init()
            return
        }
        
        appReceipt = Fallible(try AppReceipt(unsignedData: payloadData))
        
        super.init()
    }
}
