//
//  DescriptionTransformer.swift
//  Checkout Viewer
//
//  Created by Brent Royal-Gordon on 11/7/17.
//  Copyright © 2017 Architechies. All rights reserved.
//

import Foundation

class DescriptionTransformer: ValueTransformer {
    override func transformedValue(_ value: Any?) -> Any? {
        return value.map(String.init(describing:))
    }
}
