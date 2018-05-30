//
//  UserDefaultsController.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/25/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit

public class UserDefaultsController: NSObject {
    
    // Description: The UserDefaultsController is the controller for the User Defaults that are unique to the user and their schedule.  There are schedule defaults and there are notification defaults.  The schedule defaults included the patch expiration interval (timeInterval) and the quantity of estrogen in patches or shorts in the schedule.  The notification defaults includes a bool indicatinng whether the user wants a reminder and the time before expiration that the user would wish to receive the reminder.  It also includes a bool for the Suggest Location Functionality.
    
    // App
    static private var defaults = UserDefaults.standard
    
    // Schedule defaults:
    static private var deliveryMethod: String = PDStrings.deliveryMethods[0]
    static private var timeInterval: String = PDStrings.expirationIntervals[0]
    static internal var quantity: String =  PDStrings.counts[3]
    static private var slf: Bool = true
    
    // Notification defaults:
    static private var remindMeUpon: Bool = false
    static private var reminderTime: String = PDStrings.notificationSettings[0]
    
    // Rememberance
    static private var mentionedDisclaimer: Bool = false

    // MARK: - a static initializer
    
    public static func setUp() {
        self.loadDeliveryMethod()
        self.loadTimeInterval()
        self.loadQuantity()
        self.loadNotificationOption()
        self.loadSLF()
        self.loadRemindUpon()
        self.loadMentionedDisclaimer()
    }
    
    // MARK: - Getters
    
    public static func getDeliveryMethod() -> String {
        return self.deliveryMethod
    }
    
    public static func getTimeInterval() -> String {
        return self.timeInterval
    }
    
    public static func getQuantityString() -> String {
        return self.quantity
    }
    
    public static func getQuantityInt() -> Int {
        if let int = Int(self.quantity) {
            return int
        }
        else {
            return -1
        }
    }
    
    public static func getNotificationTimeString() -> String {
        return self.reminderTime
    }
    
    public static func getNotificationTimeInt() -> Int {
        // remove word "minutes"
        let min: String = self.cutNotificationMinutes(of: self.reminderTime)
        if let int = Int(min) {
            return int
        }
        else {
            return -1
        }
    }
    
    public static func getNotificationTimeDouble() -> Double {
        // remove word "minutes"
        let min: String = self.cutNotificationMinutes(of: self.reminderTime)
        if let double = Double(min) {
            return double
        }
        else {
            return -1
        }
    }
    
    public static func getSLF() -> Bool {
        return self.slf
    }
    
    public static func getRemindMeUpon() -> Bool {
        return self.remindMeUpon
    }

    public static func getMentionedDisclaimer() -> Bool {
        return self.mentionedDisclaimer
    }
    
    // MARK: - Setters
    
    public static func setDeliveryMethodWithoutWarning(to: String) {
        self.deliveryMethod = to
        self.defaults.set(to, forKey: PDStrings.deliveryMethod_key())
        defaults.synchronize()
        let c = (UserDefaultsController.getDeliveryMethod() == PDStrings.deliveryMethods[0]) ? PDStrings.counts[2] : PDStrings.counts[0]
        UserDefaultsController.setQuantityWithoutWarning(to: c)
        ScheduleController.deliveryMethodChanged = true
    }
    
    public static func setTimeInterval(to: String) {
        self.timeInterval = to
        self.defaults.set(to, forKey: PDStrings.interval_key())
        defaults.synchronize()
    }
    
    /******************************************************************
    setQuantityWithWarning(to, oldCount, countButton) : Will warn the user if they are about to delete delivery data.  It is necessary to reset MOs that are no longer in the schedule, which happens when the user has is decreasing the count in a full schedule. Resetting unused MOs makes sorting the schedule less error prone and more comprehensive.
    *****************************************************************/
    public static func setQuantityWithWarning(to: String, oldCount: Int, countButton: UIButton) {
        ScheduleController.oldDeliveryCount = oldCount
        if let newCount = Int(to), self.isAcceptable(count: newCount) {
            // startAndNewCount : represents two things.  1.) It is the start index for reseting patches that need to be reset from decreasing a full schedule, and 2.), it is the Int form of the new count
            if let startAndNewCount = Int(to) {
                // DECREASING COUNT
                if startAndNewCount < oldCount {
                    ScheduleController.decreasedCount = true        // animate schedule
                    // alert
                    if !ScheduleController.schedule().isEmpty(fromThisIndexOnward:
                        startAndNewCount) {
                        PDAlertController.alertForChangingCount(oldCount: oldCount, newCount: to, countButton: countButton)
                        return
                    }
                    else {
                        self.setQuantityWithoutWarning(to: to)  // don't alert
                    }
                }
                // INCREASING COUNT
                else {                                          // don't alert
                    self.setQuantityWithoutWarning(to: to)
                    ScheduleController.increasedCount = true        // animate schedule
                }
            }
        }
    }
    
    public static func setQuantityWithoutWarning(to: String) {
        // sets if greater than 0 and less than 5 first.
        if let newCount = Int(to), self.isAcceptable(count: newCount) {
            self.quantity = to
            self.defaults.set(to, forKey: PDStrings.count_key())
            defaults.synchronize()
        }
    }
    
    public static func setNotificationOption(to: String) {
        self.reminderTime = to
        self.defaults.set(to, forKey: PDStrings.notif_key())
        defaults.synchronize()
    }
    
    public static func setSLF(to: Bool) {
        self.slf = to
        self.defaults.set(to, forKey: PDStrings.slf_key())
        defaults.synchronize()
    }
    
    static func setRemindMeUpon(to: Bool) {
        self.remindMeUpon = to
        self.defaults.set(to, forKey: PDStrings.rMeUpon_key())
        defaults.synchronize()
    }

    public static func setMentionedDisclaimer(to: Bool) {
        self.mentionedDisclaimer = to
        self.defaults.set(to, forKey: PDStrings.mentionedDisc_key())
        defaults.synchronize()
    }
    
    //MARK: - Other public
    
    static public func format(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d, yyyy, h:mm a"
        return dateFormatter.string(from: date)
    }
    
    // MARK: - loaders
    
    static private func loadDeliveryMethod() {
        if let dm = self.defaults.object(forKey: PDStrings.deliveryMethod_key()) as? String {
            self.deliveryMethod = dm
        }
        else {
            self.setDeliveryMethodWithoutWarning(to: PDStrings.deliveryMethods[0])
        }
    }
    
    static private func loadTimeInterval() {
        if let interval = self.defaults.object(forKey: PDStrings.interval_key()) as? String {
            self.timeInterval = interval
        }
        else {
            self.setTimeInterval(to: PDStrings.expirationIntervals[0])
        }
    }
    
    static private func loadQuantity() {
        if let countStr = self.defaults.object(forKey: PDStrings.count_key()) as? String {
            // contrain patch count
            if let countInt = Int(countStr), (countInt >= 1 || countInt <= 4) {
                self.quantity = countStr
            }
            else {
                self.setQuantityWithoutWarning(to: PDStrings.counts[2])
            }
        }
        else {
            self.setQuantityWithoutWarning(to: PDStrings.counts[2])
        }
    }
    
    static private func loadNotificationOption() {
        if let notifyTime = defaults.object(forKey: PDStrings.notif_key()) as? String {
            self.reminderTime = notifyTime
        }
        else {
            self.setNotificationOption(to: PDStrings.notificationSettings[0])
        }
    }
    
    static private func loadSLF() {
        if let suggest = defaults.object(forKey: PDStrings.slf_key()) as? Bool {
            self.slf = suggest
        }
        else {
            self.setSLF(to: true)
        }
    }
    
    static private func loadRemindUpon() {
        if let notifyMe = defaults.object(forKey: PDStrings.rMeUpon_key()) as? Bool {
            self.remindMeUpon = notifyMe
        }
        else {
            self.setRemindMeUpon(to: true)
        }
    }

    static private func loadMentionedDisclaimer() {
        if let mentioned = defaults.object(forKey: PDStrings.mentionedDisc_key()) as? Bool {
            self.mentionedDisclaimer = mentioned
        }
    }
    
    // MARK: - helpers
    
    static private func isAcceptable(count: Int) -> Bool {
        // checks to see if count is reasonable for PatchDay
        if count > 0 && count <= 4 {
            return true
        }
        else {
            return false
        }
    }
    
    // cutNotificationMinutes(of) : remove the word "minutes" from the notification option
    static private func cutNotificationMinutes(of: String) -> String {
        var builder = ""
        for c in of {
            if c == " " {
                return builder
            }
            builder += String(c)
        }
        return builder
    }

}
