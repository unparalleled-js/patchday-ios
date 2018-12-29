//
//  PDSchedule.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/13/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import Foundation
import UIKit
import PDKit

public typealias SiteSet = [String]

public class PDSchedule: NSObject {
    
    override public var description: String {
        return "Singleton for reading, writing, and querying Core Data objects."
    }
    
    // Sub-schedules
    public static var estrogenSchedule = EstrogenSchedule()
    public static var pillSchedule = PillSchedule()
    public static var siteSchedule = SiteSchedule()
    public static var state = ScheduleState()

    // MARK: - Public

    /// Returns array of current occupied SiteNames
    public static func getCurrentSiteNamesInEstrogenSchedule() -> [SiteName] {
        return estrogenSchedule.getEstrogens().map({
            (estro: MOEstrogen) -> SiteName in
            if let site = estro.getSite(), let name = site.getName() {
                return name
            }
            else {
                return ""
            }
        }).filter() {
            $0 != ""
        }
    }
    
    /// Returns the next site in the site schedule as a suggestion of where to relocate.
    public static func suggest(current: Index) -> MOSite? {
        let sites = siteSchedule.getSites()
        if let i = siteSchedule.nextIndex(current: current) {
            return sites[i]
        }
        return nil
    }
    
    /// Returns the total due of MOEstrogens and MOPills in the schedule.
    public static func totalDue(interval: String) -> Int {
        return estrogenSchedule.totalDue(interval) + pillSchedule.totalDue()
    }
    
    /// For patches, get the next due. For injections, get the only one.
    public static func getEstrogenForToday() -> MOEstrogen? {
        if PDDefaults.usingPatches(),
            let estro = estrogenSchedule.nextDue() {
            return estro
        } else {
            return estrogenSchedule.getEstrogen(at: 0)
        }
    }

    /// Returns array of occupied site indices.
    public static func getOccupiedSiteIndices() -> [Index] {
        var indices: [Index] = []
        for estro in estrogenSchedule.getEstrogens() {
            if let site = estro.getSite(),
                let index = siteSchedule.getSites().index(of: site) {
                indices.append(index)
            } else {
                indices.append(-1)
            }
        }
        return indices
    }
}
