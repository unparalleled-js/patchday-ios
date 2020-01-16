//
//  QuantityUD.swift
//  PatchData
//
//  Created by Juliya Smith on 4/28/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public class QuantityValueHolder: ComplexValueHolding {
    
    public typealias KeyIndex = Quantity
    public typealias RawValue = Int
    
    var indexer: Quantity
    
    required public init(indexer: Quantity) {
        self.indexer = indexer
    }
    
    public var heldValue: Int {
        switch indexer {
        case .One: return 1
        case .Two: return 2
        case .Three: return 3
        case .Four: return 4
        }
    }
}

public class QuantityUD: KeyStorable {
    
    private var v: Quantity
    private var valueHolder: QuantityValueHolder
    
    public typealias Value = Quantity
    public typealias RawValue = Int
    
    public required convenience init(_ val: Int) {
        var count: Quantity;
        if let q = Quantity.init(rawValue: val) {
            count = q
        } else {
            count = Quantity.Four
        }
        self.init(count)
    }
    
    public required init(_ val: Quantity) {
        v = val
        valueHolder = QuantityValueHolder(indexer: v)
    }
    
    public convenience required init() {
        self.init(.Four)
    }
    
    public var value: Quantity {
        get { v }
        set {
            v = newValue
            valueHolder = QuantityValueHolder(indexer: value)
        }
    }
    
    public var rawValue: Int { valueHolder.heldValue }
    
    public static var key = PDDefault.Quantity
}