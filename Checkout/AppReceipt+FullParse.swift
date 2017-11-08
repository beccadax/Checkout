//
//  AppReceipt+FullParse.swift
//  Checkout
//
//  Created by Brent Royal-Gordon on 11/5/17.
//  Copyright © 2017 Architechies. All rights reserved.
//

import Foundation

extension AppReceipt {
    public init(unsignedData data: Data) throws {
        let decoder = ReceiptPayloadDecoder()
        self = try decoder.decode(AppReceipt.self, from: data)
    }
    
    public init(signedData data: Data) throws {
        let container = try SignedContainer(data: data)
        let payloadData = try container.verifiedContents()
        try self.init(unsignedData: payloadData)
    }
    
    public init(contentsOf url: URL) throws {
        let signedData = try Data(contentsOf: url)
        try self.init(signedData: signedData)
    }
    
    public static func current() throws -> AppReceipt {
        guard
            let url = Bundle.main.appStoreReceiptURL,
            (try? url.checkResourceIsReachable()) ?? false
        else {
            throw CheckoutError.noReceiptInMainBundle
        }
        return try AppReceipt(contentsOf: url)
    }
}
