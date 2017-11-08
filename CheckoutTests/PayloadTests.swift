//
//  PayloadTests.swift
//  CheckoutTests
//
//  Created by Brent Royal-Gordon on 11/6/17.
//  Copyright © 2017 Architechies. All rights reserved.
//

import XCTest
@testable import Checkout

func XCTAssertSome<T>(_ value: T?, _ message: String, file: StaticString = #file, line: UInt = #line, then body: (T) throws -> Void) rethrows {
    if let value = value {
        try body(value)
    }
    else {
        XCTFail(message, file: file, line: line)
    }
}

class PayloadTests: XCTestCase {
    func testParsePayload() throws {
        _ = try ReceiptPayload(data: payloadData())
    }
    
    func testPayloadContents() throws {
        let payload = try ReceiptPayload(data: payloadData())
        XCTAssertEqual(payload.attributes.count, 21)
        
        XCTAssertSome(payload.attributes.first(where: { $0.type == 0 }), "Receipt does not contain a receipt type attribute") { attribute in
            XCTAssertEqual(attribute.type, 0)
            XCTAssertEqual(attribute.version, 1)
            XCTAssertNotEqual(attribute.value, Data())
        }
    }
    
    func testPayloadAttributeValueMethods() throws {
        let payload = try ReceiptPayload(data: payloadData())
        
        try XCTAssertSome(payload.attributes.first(where: { $0.type == 0 }), "Receipt does not contain a receipt type attribute") { attributes in
            XCTAssertEqual(try attributes.utf8StringValue(), "Production")
            
            XCTAssertThrowsError(try attributes.ia5StringValue()) { error in
                XCTAssert(OpenSSLWrapperError.wrongObjectTag ~= error)
            }
            XCTAssertThrowsError(try attributes.dateValue()) { error in
                XCTAssert(OpenSSLWrapperError.wrongObjectTag ~= error)
            }
            XCTAssertThrowsError(try attributes.intValue()) { error in
                XCTAssert(OpenSSLWrapperError.wrongObjectTag ~= error)
            }
        }
        
        try XCTAssertSome(payload.attributes.first(where: { $0.type == 12 }), "Receipt does not contain a receipt creation date attribute") { attribute in
            XCTAssertEqual(try attribute.ia5StringValue(), "2017-10-31T16:59:28Z")
            XCTAssertEqual(try attribute.dateValue(), Date(timeIntervalSinceReferenceDate: 531161968.0))
            
            XCTAssertThrowsError(try attribute.utf8StringValue()) { error in
                XCTAssert(OpenSSLWrapperError.wrongObjectTag ~= error)
            }
            XCTAssertThrowsError(try attribute.intValue()) { error in
                XCTAssert(OpenSSLWrapperError.wrongObjectTag ~= error)
            }
        }
    }
}
