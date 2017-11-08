//
//  ReceiptTests.swift
//  CheckoutTests
//
//  Created by Brent Royal-Gordon on 11/6/17.
//  Copyright © 2017 Architechies. All rights reserved.
//

import XCTest
@testable import Checkout

class ReceiptTests: XCTestCase {
    func testParseReceipt() throws {
        _ = try AppReceipt(unsignedData: payloadData())
    }
    
    func testAppReceiptFields() throws {
        let receipt = try AppReceipt(unsignedData: payloadData())
        
        XCTAssertEqual(receipt.bundleID, "com.architechies.touch.Converter") 
        XCTAssertEqual(receipt.appVersion, "1.14.7") 
        XCTAssertEqual(receipt.sha1Hash.count, 20) 
        XCTAssertEqual(receipt.sha1Hash, Data(base64Encoded: "4fZW9bUh/ROHAroDKbl/pzLR5fg=")) 
        XCTAssertEqual(receipt.receiptType, "Production") 
        XCTAssertEqual(receipt.originalAppVersion, "2.2.2") 
        XCTAssertEqual(receipt.originalPurchaseDate, Date(timeIntervalSinceReferenceDate: 281567658.0))
        XCTAssertEqual(receipt.ageRating, "4+")
        XCTAssertEqual(receipt.receiptCreationDate, Date(timeIntervalSinceReferenceDate: 531161968.0))
        XCTAssertEqual(receipt.receiptExpirationDate, nil)
    }
    
    func testPurchaseReceiptFields() throws {
        let receipt = try AppReceipt(unsignedData: payloadData())
        let purchases = receipt.purchaseReceipts
        
        XCTAssertFalse(purchases.isEmpty)
    }
}
