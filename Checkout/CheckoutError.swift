//
//  CheckoutError.swift
//  Checkout
//
//  Created by Brent Royal-Gordon on 11/5/17.
//  Copyright © 2017 Architechies. All rights reserved.
//

import Foundation

public enum CheckoutError: Error {
    case invalidSignature(underlying: Error)
    case missingSignature
    case missingContents
    case invalidDate
    case noReceiptInMainBundle
}
