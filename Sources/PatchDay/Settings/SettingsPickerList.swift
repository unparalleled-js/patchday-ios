//
//  SettingsPickerList.swift
//  PDKit
//
//  Created by Juliya Smith on 5/2/21.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

class SettingsPickerList {
    private let quantityPicker: SettingsPicking
    private let deliveryMethodPicker: SettingsPicking
    private let expirationIntervalPicker: ExpirationIntervalSettingsPicking
    private lazy var log = PDLog<SettingsPickerList>()

    init(
        quantityPicker: SettingsPicking,
        deliveryMethodPicker: SettingsPicking,
        expirationIntervalPicker: ExpirationIntervalSettingsPicking
    ) {
        self.quantityPicker = quantityPicker
        self.deliveryMethodPicker = deliveryMethodPicker
        self.expirationIntervalPicker = expirationIntervalPicker
    }

    var all: [SettingsPicking] {
        [
            quantityPicker,
            deliveryMethodPicker,
            expirationIntervalPicker
        ]
    }

    subscript(_ setting: PDSetting) -> SettingsPicking? {
        switch setting {
            case .Quantity: return quantityPicker
            case .DeliveryMethod: return deliveryMethodPicker
            case .ExpirationInterval: return expirationIntervalPicker.forIntervals
            case .XDays: return expirationIntervalPicker.forXDays
            default:
                log.error("No picker for given setting \(setting)")
                return nil
        }
    }

    @discardableResult
    func select(_ setting: PDSetting) -> SettingsPicking? {
        guard let selectedPicker = self[setting] else { return nil }
        for picker in all where picker.view != selectedPicker.view {
            picker.close(setSelectedRow: false)
        }
        return selectedPicker
    }
}
