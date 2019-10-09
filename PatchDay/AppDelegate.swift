//
//  AppDelegate.swift
//  test
//
//  Created by Juliya Smith on 5/9/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit

// Mock these for testing
import UserNotifications
import PatchData

let app = (UIApplication.shared.delegate as! AppDelegate)
let isResetMode = false  // Change this to true to nuke the database

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var notifications: PDNotificationScheduling = PDNotifications()
    var sdk: PatchDataDelegate = PatchDataSDK(swallowHandler: PDSwallower())
    var alerts = PDAlertDispatcher()
    var tabs: PDTabReflector?
    var nav: PDNavigationDelegate = PDNavigationDelegate()
    var styles: PDStyling!

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        if isFirstLaunch() {
            self.sdk.pills.new()
        }
        if isResetMode {
            sdk.nuke()
            return false
        }
        self.styles = PDStylist(theme: self.sdk.defaults.theme.value)
        self.sdk.broadcastHormones()
        self.setBadge()
        self.setNavigationAppearance()
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        setBadge()
    }

    func applicationWillResignActive(_ application: UIApplication) {
        setBadge()
    }

    func setTabs(tc: UITabBarController, vcs: [UIViewController]) {
        tabs = PDTabReflector(tabController: tc, viewControllers: vcs)
    }

    func isFirstLaunch() -> Bool {
        return !sdk.defaults.mentionedDisclaimer.value
    }

    func setNavigationAppearance() {
        nav.reflectTheme(theme: styles.theme)
        tabs?.reflectTheme(theme: styles.theme)
    }

    func resetTheme() {
        let t = sdk.defaults.theme.value
        self.styles = PDStylist(theme: t)
        setNavigationAppearance()
    }

    /// Sets the App badge number to the expired count + the total pills due for taking.
    private func setBadge() {
        UIApplication.shared.applicationIconBadgeNumber = sdk.totalDue
    }
}
