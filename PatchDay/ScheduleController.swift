//
//  ScheduleController.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/13/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import PDKit

// ScheduleController is the public accessor class for controlling the app's managed objects.  A PatchDay Managed Object is known as a "Patch" or an "Injection", an abstraction of a patch on the physical body or an injection into the physical body.  The ScheduleController is how the user changes any of their patches or re-injects.  The user may also use the ScheduleController to edit a MOEstrogen object's attributes.  This static class uses a "Schedule" object to work with all of the MOEstrogens together in an array.  Schedule objects are for querying an array of MOEstrogens.

public class ScheduleController: NSObject {
    
    public static var estrogenController = EstrogenDataController(context: ScheduleController.persistentContainer.viewContext)
    public static var pillController = PillDataController(context: ScheduleController.persistentContainer.viewContext)
    public static var siteController = SiteDataController(context: ScheduleController.persistentContainer.viewContext)
    
    // MARK: - Core Data stack
    
    internal static var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: PDStrings.CoreDataKeys.persistantContainer_key)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                PDAlertController.alertForPersistentStoreLoadError(error: error)
            }
        })
        return container
    }()
    
    /***********************************************************
    for button animation algorithm : knowing which buttons to animate when loading EstrogensVC
    ***********************************************************/
    internal static var animateScheduleFromChangeDelivery: Bool = false
    internal static var increasedCount: Bool = false
    internal static var decreasedCount: Bool = false
    internal static var onlySiteChanged: Bool = false
    internal static var deliveryMethodChanged: Bool = false
    internal static var oldDeliveryCount: Int = 1
    internal static var indexOfChangedDelivery: Int = -1
    
    // MARK: - Public
    
    public static func estrogenSchedule(estrogens: [MOEstrogen]) -> EstrogenSchedule {
        return EstrogenSchedule(estrogens: estrogens)
    }
    
    public static func siteSchedule(sites: [MOSite]) -> SiteSchedule {
        return SiteSchedule(siteScheduleArray: sites)
    }
    
    public static func totalEstrogenAndPillsDue() -> Int {
        // Estrogens expired
        let estrogens = estrogenController.estrogenArray
        let estrogenSchedule = ScheduleController.estrogenSchedule(estrogens: estrogens)
        let intervalStr = UserDefaultsController.getTimeIntervalString()
        let expiredCount = estrogenSchedule.expiredCount(intervalStr)
        
        // Pills due
        let pillsTakenTodays = ScheduleController.pillController.getPillTimesTakens()
        let nextPillDueDates = ScheduleController.pillController.getNextPillDueDates()
        let totalPillsDue = PDPillsHelper.totalDue(timesTakensToday: pillsTakenTodays, nextDueDates: nextPillDueDates)
        
        return expiredCount + totalPillsDue
    }
 
    /* 1.) Loop throug the Estrogen Delivery MOs
       2.) Get the site index for each Estrogen Delivery getLocation()
       3.) Make sure i is a valid index for the Site Schedule Array
       4.) If site index from step 2 is not equal to i, that means
              we should readjust.
    
    */
    
    /*************************************************************
     ANIMATION ALGORITHM
     *************************************************************/
    public static func shouldAnimate(scheduleIndex: Int, newBG: UIImage, estrogenController: EstrogenDataController) -> Bool {
        
        /* -- Reasons to Animate -- */
        
        var hasDateAndItMatters: Bool = true
        if let estro = estrogenController.getEstrogenMO(at: scheduleIndex), estro.hasNoDate() {
            hasDateAndItMatters = false
        }
        
        // 1.) from DETAILS: animate affected non-empty MO dates from changing
        let moreThanSiteChangedFromDetails: Bool = animateScheduleFromChangeDelivery && newBG != PDImages.addPatch  && !onlySiteChanged && indexOfChangedDelivery <= scheduleIndex && hasDateAndItMatters
        
        // 2.) from DETAILS: animate the newly changed site and none else (date didn't change)
        let isChangedSiteFromDetails: Bool = onlySiteChanged && scheduleIndex == indexOfChangedDelivery
        
        // 3.) from SETTINGS: animate new empty MOs when loading from the changing count
        let indexLessThanOldCountFromSettings: Bool = (increasedCount && scheduleIndex >= oldDeliveryCount)

        return (moreThanSiteChangedFromDetails || isChangedSiteFromDetails || indexLessThanOldCountFromSettings || deliveryMethodChanged)
        
    }


}
