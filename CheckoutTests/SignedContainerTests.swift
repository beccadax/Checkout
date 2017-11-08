//
//  SignedContainerTests.swift
//  SignedContainerTests
//
//  Created by Brent Royal-Gordon on 11/5/17.
//  Copyright © 2017 Architechies. All rights reserved.
//

import XCTest
@testable import Checkout

class SignedContainerTests: XCTestCase {
    func testBIO() throws {
        let bio = try _BIO(data: receiptData)
        
        let outData = try bio.readData(ofLength: 20_000)
        
        XCTAssertEqual(outData.count, receiptData.count, "Reads full file")
        XCTAssertEqual(outData, receiptData, "All data matches")
    }
    
    func testConstruct() throws {
        _ = try SignedContainer(data: receiptData)
    }
    
    func testVerify() throws {
        let container = try SignedContainer(data: receiptData)
        _ = try container.verifiedContents()
    }
    
    func testContents() throws {
        let container = try SignedContainer(data: receiptData)
        let contents = try container.verifiedContents()
        
        XCTAssertNotEqual(contents.count, 0, "Has contents")
    }
}
