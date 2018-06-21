//
//  NotificationController.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/6/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import UserNotifications
import PDKit

internal class PDNotificationController: NSObject, UNUserNotificationCenterDelegate {
    
    // Description:  class for controlling PatchDay's notifications.
    
    // MARK: - Essential
    
    internal var center = UNUserNotificationCenter.current()
    internal var currentScheduleIndex = 0
    internal var sendingNotifications = true
    internal var pillMode: Int = -1
    
    private var chgActionID = { return "changeActionID" }()
    private var tkActionID = { return "takeActionID" }()
    private var chgCategoryID = { return "changeCategoryID" }()
    private var tkCategoryID = { return "takeCategoryID"}()
    
    override init() {
        super.init()
        self.center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            // Enable or disable features based on authorization, granted is a bool meaning it errored
        }
        UNUserNotificationCenter.current().delegate = self
    }
    
    internal func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // ACTION:  Autofill pressed
        if response.actionIdentifier == chgActionID {
            if ScheduleController.coreDataController.getEstrogenDeliveryMO(forIndex: currentScheduleIndex) != nil {
                // Suggested date and time is the current date and time
                var suggestedSite: String? = suggestSite()
                if suggestedSite == nil {
                    suggestedSite = PDStrings.placeholderStrings.new_site
                }
                let suggestDate = Date()
                ScheduleController.coreDataController.setEstrogenDeliveryMO(scheduleIndex: currentScheduleIndex, date: suggestDate, location: suggestedSite!)
                UIApplication.shared.applicationIconBadgeNumber -= 1
            }
        }
        else if response.actionIdentifier == tkActionID {
            let keys = [PDStrings.SettingsKey.tbStamp.rawValue, PDStrings.SettingsKey.pgStamp.rawValue]
            let dailies = [PillDataController.getTBDailyInt(), PillDataController.getPGDailyInt()]
            var stamps: Stamps = []
            // Temp stamps gets member stamps
            if pillMode == 0, let tb_s = PillDataController.tb_stamps{
                stamps = tb_s
            }
            else if pillMode == 1 , let pg_s = PillDataController.pg_stamps {
                stamps = pg_s
            }
            // Take, use temp stamps
            PillDataController.take(this: &stamps, at: Date(), timesaday: dailies[pillMode], key: keys[pillMode])
            // Member stamps get temp stamps
            if pillMode == 0 {
                PillDataController.tb_stamps = stamps
            }
            else if pillMode == 1 {
                PillDataController.pg_stamps = stamps
            }
            UIApplication.shared.applicationIconBadgeNumber -= 1
        }
    }

    // MARK: - notifications
    
    /****************************************************
     requestNotifiyExpired(mode) : For expired patches or injection.
     ****************************************************/
    internal func requestNotifyExpired(scheduleIndex: Int) {
        let notifyTime = UserDefaultsController.getNotificationTimeDouble()
        if let estro = ScheduleController.coreDataController.getEstrogenDeliveryMO(forIndex: scheduleIndex), sendingNotifications,
            UserDefaultsController.getRemindMeUpon(), var timeIntervalUntilExpire = estro.determineIntervalToExpire(timeInterval: UserDefaultsController.getTimeInterval()) {
            currentScheduleIndex = scheduleIndex
            // Notification's attributes
            let content = UNMutableNotificationContent()
            if (UserDefaultsController.usingPatches()) {
                content.title = (notifyTime == 0) ? PDStrings.notificationStrings.titles.patchExpired : PDStrings.notificationStrings.titles.patchExpires
            }
            else {
                content.title = (notifyTime == 0) ? PDStrings.notificationStrings.titles.injectionExpired : PDStrings.notificationStrings.titles.injectionExpires
            }
            content.body = estro.notificationMessage(timeInterval: UserDefaultsController.getTimeInterval())
            content.sound = UNNotificationSound.default()
            content.badge = ScheduleController.estrogenSchedule().expiredCount(timeInterval: UserDefaultsController.getTimeInterval()) + PillDataController.totalDue() + 1 as NSNumber

            // ChangeAction is an action for changing the patch from a notification using the Autofill Site Functionality (the SLF Bool from the Settings must be True) and the current date and time.
            let changeAction = UNNotificationAction(identifier: chgActionID, title: PDStrings.notificationStrings.actionMessages.autofill, options: [])
                
            // Add the action int the category
            let changeCategory = UNNotificationCategory(identifier: chgCategoryID, actions: [changeAction], intentIdentifiers: [], options: [])
            center.setNotificationCategories([changeCategory])
                
            // Suggest site in the notification body text
            let msg = (UserDefaultsController.usingPatches()) ? PDStrings.notificationStrings.messages.siteForNextPatch : PDStrings.notificationStrings.messages.siteForNextInjection
            if let additionalMessage = suggestSiteMessage(msg: msg) {
                content.body += additionalMessage
            }
                
            // Adopt category
            content.categoryIdentifier = "changeCategoryID"
            
            // Trigger
            timeIntervalUntilExpire = timeIntervalUntilExpire - (notifyTime * 60.0)
            if timeIntervalUntilExpire > 0 {
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeIntervalUntilExpire, repeats: false)
                // Request
                if scheduleIndex >= 0 && scheduleIndex < PDStrings.notificationIDs.expiredIDs.count {
                    let id = PDStrings.notificationIDs.expiredIDs[scheduleIndex]
                    let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger) // Schedule the notification.
                    center.add(request) { (error : Error?) in
                        if error != nil {
                            print("Unable to Add Notification Request (\(String(describing: error)), \(String(describing: error?.localizedDescription)))")
                        }
                    }
                }
            }
        }
    }
    
    /****************************************************
    requestNotifiyTakePill(mode) : Where mode = 0 means TB,
                                   mode = 1 means PG.
    ****************************************************/
    internal func requestNotifyTakePill(mode: Int) {
        pillMode = mode
        if !sendingNotifications {
            return
        }
        // Each array is 1x2, mode picks the correct values corresponding to TB or PG.
        let titles: [String] = [PDStrings.notificationStrings.titles.takeTB, PDStrings.notificationStrings.titles.takePG]
        let messages: [String] = [PDStrings.notificationStrings.messages.takeTB, PDStrings.notificationStrings.messages.takePG]
        let timesadays: [Int] = [PillDataController.getTBDailyInt(), PillDataController.getPGDailyInt()]
        let stamps: [Date?] = [PDPillsHelper.getLaterStamp(stamps: PillDataController.tb_stamps), PDPillsHelper.getLaterStamp(stamps: PillDataController.pg_stamps)]
        let firstTimes: [Date?] = [PillDataController.getTB1Time(), PillDataController.getPG1Time()]
        let secondTimes: [Date?] = [PillDataController.getTB2Time(), PillDataController.getPG2Time()]
        let content = UNMutableNotificationContent()
        
        // Content
        content.title = titles[mode]
        content.body = messages[mode]
        content.sound = UNNotificationSound.default()
        content.badge = ScheduleController.estrogenSchedule().expiredCount(timeInterval: UserDefaultsController.getTimeInterval()) + PillDataController.totalDue() + 1 as NSNumber
        
        // Take Action
        let takeAction = UNNotificationAction(identifier: tkActionID,
                                                title: PDStrings.actionStrings.take, options: [])
        let takeCategory = UNNotificationCategory(identifier: tkCategoryID, actions: [takeAction], intentIdentifiers: [], options: [])
        center.setNotificationCategories([takeCategory])
        content.categoryIdentifier = tkCategoryID
        
        // Interval determination - TB1 or TB2? (or PG1 or PG2)
        let usingSecondTime = PDPillsHelper.useSecondTime(timesaday: timesadays[mode], stamp: stamps[mode])
        var choiceDate = Date()
        let now = Date()
        // Using Second Time
        if usingSecondTime, let secondTime = secondTimes[mode], let todayDate = PDDateHelper.getTodayDate(at: secondTime) {
            choiceDate = todayDate
        }
        // Using First Time
        else {
            if let firstTime = firstTimes[mode] {
                if stamps[mode] == nil || !Calendar.current.isDate(stamps[mode]!, inSameDayAs: Date()) {
                    if let todayDate = PDDateHelper.getTodayDate(at: firstTime) {
                        choiceDate = todayDate
                    }
                }
                else if let tomorrow = PDDateHelper.getDate(at: firstTime, daysToAdd: 1) {
                    choiceDate = tomorrow
                }
            }
        }
        
        // Only request if the choiceDate is after now
        if now < choiceDate {
            let interval = choiceDate.timeIntervalSince(now)
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
            // Request
            if mode >= 0 && mode < PDStrings.notificationIDs.pillIDs.count {
                let id = PDStrings.notificationIDs.pillIDs[mode]
                let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger) // Schedule the notification.
                center.add(request) { (error : Error?) in
                    if error != nil {
                        print("Unable to Add Notification Request (\(String(describing: error)), \(String(describing: error?.localizedDescription)))")
                    }
                }
            }
        }
    }
    
    internal func cancelSchedule(index: Int) {
        if index >= 0 && index < PDStrings.notificationIDs.expiredIDs.count {
            let id = PDStrings.notificationIDs.expiredIDs[index]
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
        }
    }
    
    internal func cancelPills(identifiers: [String]) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    // MARK: - Private helpers
    
    private func suggestSite() -> String? {
        let scheduleSites: [String] = ScheduleController.siteSchedule().siteNamesArray
        let currentSites: [String] = ScheduleController.estrogenSchedule().currentSiteNames
        let estroSiteName: String = currentSites[currentScheduleIndex]
        let estroCount: Int = UserDefaultsController.getQuantityInt()
        if let suggestSiteIndex = SiteSuggester.suggest(currentEstrogenSiteSuggestingFrom: estroSiteName, currentSites: currentSites, estrogenQuantity: estroCount, scheduleSites: scheduleSites), suggestSiteIndex >= 0 && suggestSiteIndex < scheduleSites.count {
            return scheduleSites[suggestSiteIndex]
        }
        return nil
    }
    
    private func suggestSiteMessage(msg: String) -> String? {
        if let suggestedSiteName = suggestSite() {
            return "\n\n" + msg + suggestedSiteName
        }
        return nil
    }
    
}
