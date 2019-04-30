//
//  PDPickerStrings.swift
//  PDKit
//
//  Created by Juliya Smith on 4/29/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

public class PDPickerStrings {
    
    public static func getPickerStrings(for key: PDDefault) -> [String] {
        switch key {
        case PDDefault.DeliveryMethod:
            return deliveryMethods
        case PDDefault.ExpirationInterval:
            return expirationIntervals
        case PDDefault.Quantity:
            return quantities
        case PDDefault.Theme:
            return themes
        default:
            return []
        }
    }
    
    public static let deliveryMethods: [String] = {
        let comment = "Displayed on a button and in a picker."
        return [NSLocalizedString("Patches", tableName: nil, comment: comment),
                NSLocalizedString("Injections", tableName: nil, comment: comment)]
    }()
    
    public static let expirationIntervals: [String] = {
        let comment1 = "Displayed on a button and in a picker."
        let comment2 = "Displayed in a picker."
        return [NSLocalizedString("Twice a week", tableName: nil, comment: comment1),
                NSLocalizedString("Once a week", tableName: nil, comment: comment2),
                NSLocalizedString("Once every two weeks", comment: comment1)]
    }()
    
    public static let quantities: [String] = {
        let comment = "Displayed in a picker."
        return [NSLocalizedString("1", comment: comment),
                NSLocalizedString("2", comment: comment),
                NSLocalizedString("3", comment: comment),
                NSLocalizedString("4", comment: comment)]
    }()
    
    public static let themes: [String] = {
        let comment = "Displayed in a picker."
        return [NSLocalizedString("Light", comment: comment),
                NSLocalizedString("Dark", comment: comment)]
    }()
    
    public static let pillCounts: [String] = { return [quantities[0], quantities[1]] }()
    
    private static let comment1 = "Displayed on a button and in a picker."
    private static let comment2 = "Displayed in a picker."
    
}
