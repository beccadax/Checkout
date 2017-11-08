//
//  AppReceipt.swift
//  Checkout
//
//  Created by Brent Royal-Gordon on 11/5/17.
//  Copyright © 2017 Architechies. All rights reserved.
//

import Foundation

public func payloadReceiptAttributeTypeName(for type: Int) -> String? {
    return AppReceipt.CodingKeys(intValue: type)?.stringValue ?? PurchaseReceipt.CodingKeys(intValue: type)?.stringValue
}

public struct AppReceipt: Decodable {
    public var bundleID: String
    public var appVersion: String
    public var opaqueValue: Data
    public var sha1Hash: Data
    
    public var receiptCreationDate: Date?
    public var receiptExpirationDate: Date?
    
    public var ageRating: String?
    public var receiptType: String?
    
    public var originalAppVersion: String?
    public var originalPurchaseDate: Date?
    
    public var purchaseReceipts: [PurchaseReceipt]
    
    enum CodingKeys: Int, CodingKey {
        case bundleID = 2
        case appVersion = 3
        case opaqueValue = 4
        case sha1Hash = 5
        
        case receiptCreationDate = 12
        case receiptExpirationDate = 21
        
        case ageRating = 10
        case receiptType = 0
        case originalAppVersion = 19
        case originalPurchaseDate = 18
        
        case purchaseReceipts = 17
    }
}

public struct PurchaseReceipt: Decodable {
    public var quantity: Int
    public var productID: String
    public var transactionID: String
    public var purchaseDate: Date
    
    public var originalTransactionID: String?
    public var originalPurchaseDate: Date?
    
    public var subscriptionExpirationDate: Date?
    public var cancellationDate: Date?
    public var webOrderLineItemID: Int?
    
    enum CodingKeys: Int, CodingKey {
        case quantity = 1701
        case productID = 1702
        case transactionID = 1703
        case purchaseDate = 1704
        case originalTransactionID = 1705
        case originalPurchaseDate = 1706
        case subscriptionExpirationDate = 1708
        case webOrderLineItemID = 1711
        case cancellationDate = 1712
    }
}
