//
//  NotificationsMinutesBefore.swift
//  PatchData
//
//  Created by Juliya Smith on 4/28/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public class NotificationsMinutesBeforeUD: PDKeyStorable {
    
    public typealias Value = Int
    
    public typealias RawValue = Int
    
    public var value: Int
    
    public var rawValue: Int {
        get {
            return value
        }
    }
    
    public static var key = PDDefault.NotiicationsMinutesBefore
    
    public required init(with val: Int) {
        value = val
    }
}
