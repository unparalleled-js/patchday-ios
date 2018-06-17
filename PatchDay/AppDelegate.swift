//
//  AppDelegate.swift
//  test
//
//  Created by Juliya Smith on 5/9/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import UserNotifications
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // How to get reference: "let appDelegate = UIApplication.shared.delegate as! AppDelegate"
    
    internal var window: UIWindow?
    
    internal var notificationsController = PDNotificationController()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        UserDefaultsController.setUp()
        PillDataController.setUp()
        
        // unhide for resetting (for testing):
        //CoreDataController.resetPatchData()
        
        // Navigation bar appearance
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.tintColor = UIColor.darkGray

        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Badge correction
        UIApplication.shared.applicationIconBadgeNumber = CoreDataController.schedule().expiredCount(timeInterval: UserDefaultsController.getTimeInterval()) + PillDataController.totalDue()
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        
        // Badge correction
        UIApplication.shared.applicationIconBadgeNumber = CoreDataController.schedule().expiredCount(timeInterval: UserDefaultsController.getTimeInterval()) + PillDataController.totalDue()
    }

}
