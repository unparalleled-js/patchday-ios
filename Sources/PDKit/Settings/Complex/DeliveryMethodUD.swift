//
//  DeliveryMethodUD.swift
//  PatchData
//
//  Created by Juliya Smith on 4/28/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public class DeliveryMethodUD: ComplexSetting<DeliveryMethod, String>, KeyStorable {

    public static let PatchesKey = { "Patches" }()
    public static let InjectionsKey = { "Injections" }()
    public static let GelKey = { "Gel" }()

    public typealias Value = DeliveryMethod
    public typealias RawValue = String
    public let setting: PDSetting = .DeliveryMethod

    public convenience init() {
        self.init(DefaultSettings.DeliveryMethodValue)
    }

    public convenience init(_ value: DeliveryMethod) {
        let rv = DeliveryMethodUD.getRawValue(for: value)
        self.init(rv)
    }

    public required init(_ rawValue: String) {
        super.init(rawValue)
        self.choices = SettingsOptions.deliveryMethods
    }

    public override var value: DeliveryMethod {
        switch rawValue {
            case DeliveryMethodUD.PatchesKey: return .Patches
            case DeliveryMethodUD.InjectionsKey: return .Injections
            case DeliveryMethodUD.GelKey: return .Gel
            default: return .Patches
        }
    }

    public static func getRawValue(for v: DeliveryMethod) -> String {
        switch v {
            case .Patches: return PatchesKey
            case .Injections: return InjectionsKey
            case .Gel: return GelKey
        }
    }
}