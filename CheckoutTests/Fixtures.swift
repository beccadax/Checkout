//
//  Fixtures.swift
//  CheckoutTests
//
//  Created by Brent Royal-Gordon on 11/6/17.
//  Copyright © 2017 Architechies. All rights reserved.
//

import Foundation
@testable import Checkout

let receiptURL = Bundle(for: SignedContainerTests.self).url(forResource: "user", withExtension: "receipt")!
let receiptData = try! Data(contentsOf: receiptURL)

func payloadData() throws -> Data {
    let container = try SignedContainer(data: receiptData)
    return try container.verifiedContents()
}
