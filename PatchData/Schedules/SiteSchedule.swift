//
//  SiteSchedule.swift
//  PatchDay
//
//  Created by Juliya Smith on 7/4/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import Foundation
import CoreData
import PDKit

public typealias SiteNameSet = Set<SiteName>

public class SiteSchedule: NSObject {
    
    override public var description: String {
        return "Singleton for reading, writing, and querying the MOSite array."
    }
    
    public var siteArray: [MOSite]
    
    override init() {
        let context = PatchData.getContext()
        siteArray = SiteSchedule.loadSiteMOs(into: context)
        siteArray = SiteSchedule.filterEmptySites(from: siteArray)
        if siteArray.count == 0 {
            siteArray = SiteSchedule.newSiteMOs(into: context)
        }
        siteArray.sort(by: <)
    }
    
    // MARK: - Public
    
    public func getSites() -> [MOSite] {
        return siteArray
    }

    /// Returns the site at the given index.
    public func getSite(at index: Index) -> MOSite? {
        if index >= 0 && index < siteArray.count {
            return siteArray[index]
        }
        return nil
    }
    
    /// Returns the MOSite for the given name. Appends new site with given name if doesn't exist.
    public func getSite(for name: String) -> MOSite? {
        if let index = getSiteNames().index(of: name) {
            return siteArray[index]
        }
        // Append new site
        return SiteSchedule.appendSite(name: name, sites: &siteArray)
    }
    
    /// Returns the next site for scheduling in the site schedule.
    public func getNextSiteIndex(currentIndex: Index) -> Index? {
        if siteArray.count <= 0 || currentIndex < 0 {
            return nil
        }
        var r: Index = (currentIndex < siteArray.count) ? currentIndex : 0
        for _ in 0..<siteArray.count {
            // Return site that has no estros
            if siteArray[r].estrogenRelationship?.count == 0 {
                UserDefaultsController.setSiteIndex(to: r)
                return r
            } else {
                r = UserDefaultsController.getSiteIndex()
            }
        }
        return min(currentIndex, siteArray.count-1)
    }
    
    /// Sets a the siteName for the site at the given index.
    public func setSiteName(at index: Index, to newName: String) {
        if index >= 0 && index < siteArray.count {
            siteArray[index].setName(to: newName)
            PatchData.save()
        }
    }
    
    /// Sets the site order for the site at the given index.
    public func setSiteOrder(at index: Index, to newOrder: Int16) {
        let new_order = Index(newOrder)
        if index >= 0 && index < siteArray.count && new_order < siteArray.count && new_order >= 0 {
            siteArray.sort(by: <)
            siteArray[index].setOrder(to: newOrder)
            siteArray[new_order].setOrder(to: Int16(index))
            siteArray.sort(by: <)
            PatchData.save()
        }
    }
    
    /// Sets the site image ID for the site at the given index.
    public func setSiteImageID(at index: Index, to newID: String, usingPatches: Bool) {
        let site_set = usingPatches ?
            PDStrings.SiteNames.patchSiteNames :
            PDStrings.SiteNames.injectionSiteNames
        if site_set.contains(newID), index >= 0 && index < siteArray.count {
            siteArray[index].setImageIdentifier(to: newID)
            PatchData.save()
        }
    }
    
    /// Deletes the site at the given index.
    public func deleteSite(at index: Index) {
        if index >= 0 && index < siteArray.count {
            loadEstrogenBackupSiteNameFromSite(site: siteArray[index])
            siteArray[index].reset()
        }
        if (index+1) < (siteArray.count-1) {
            for i in (index+1)..<siteArray.count {
                siteArray[i].decrement()
            }
        }
        siteArray = siteArray.filter() { $0.getOrder() != -1 && $0.getName() != ""}
        PatchData.save()
    }
    
    /// Set the siteBackUp string in the site's MOEstsrogens to the siteName.
    public func loadEstrogenBackupSiteNameFromSite(site: MOSite) {
        if site.isOccupied(),
            let estroSet = site.estrogenRelationship {
            for estro in Array(estroSet) {
                let e = estro as! MOEstrogen
                if let n = site.getName() {
                    e.setSiteBackup(to: n)
                }
            }
        }
    }
    
    /// Returns an array of a siteNames for each site in the schedule.
    public func getSiteNames() -> [SiteName] {
        return siteArray.map({
            (site: MOSite) -> SiteName? in
            return site.getName()
        }).filter() { $0 != nil } as! [SiteName]
    }
    
    /// Returns array of image IDs from array of MOSites.
    public func getSiteImageIDs() -> [String] {
        return siteArray.map({
            (site: MOSite) -> String? in
            return site.getImageIdentifer()
        }).filter() {
            $0 != nil
            } as! [String]
    }
    
    /// Returns the set of sites on record union with the set of default sites
    public func siteNameSetUnionDefaultSites(usingPatches: Bool) -> SiteNameSet {
        let defaultSitesSet = (usingPatches) ? Set(PDStrings.SiteNames.patchSiteNames) : Set(PDStrings.SiteNames.injectionSiteNames)
        let siteSet = Set(getSiteNames())
        return siteSet.union(defaultSitesSet)
    }
    
    /// Returns if the sites in the site schedule are the same as the default sites.
    public func isDefault(usingPatches: Bool) -> Bool {
        let defaultSites = (usingPatches) ? PDStrings.SiteNames.patchSiteNames : PDStrings.SiteNames.injectionSiteNames
        let c = defaultSites.count
        if siteArray.count != c {
            return false
        }
        for i in 0..<c {
            if let n = siteArray[i].getName() {
                if n != defaultSites[i] {
                    return false
                }
            } else {
                return false
            }
        }
        return true
    }

    /// Removes all sites with empty or nil names from the siteArray.
    public static func filterEmptySites(from sites: [MOSite]) -> [MOSite] {
        return sites.filter() { $0.getName() != ""
            && $0.getName() != nil
            && $0.getOrder() != -1 }
    }
    
    /// Resets the site array a default list of sites.
    public func reset(usingPatches: Bool) {
        let resetSiteNames: [String] = (usingPatches) ?
            PDStrings.SiteNames.patchSiteNames :
            PDStrings.SiteNames.injectionSiteNames
        let oldCount = siteArray.count
        let newcount = resetSiteNames.count
        for i in 0..<newcount {
            if i < siteArray.count {
                siteArray[i].setOrder(to: Int16(i))
                siteArray[i].setName(to: resetSiteNames[i])
                siteArray[i].setImageIdentifier(to: resetSiteNames[i])
            } else if let newSiteMO = NSEntityDescription.insertNewObject(forEntityName: PDStrings.CoreDataKeys.siteEntityName, into: PatchData.getContext()) as? MOSite {
                newSiteMO.setOrder(to: Int16(i))
                newSiteMO.setName(to: resetSiteNames[i])
                newSiteMO.setImageIdentifier(to: resetSiteNames[i])
                siteArray.append(newSiteMO)
            }
        }
        if oldCount > resetSiteNames.count {
            for i in resetSiteNames.count..<oldCount {
                siteArray[i].reset()
            }
        }
        siteArray = SiteSchedule.filterEmptySites(from: siteArray)
        siteArray.sort(by: <)
        PatchData.save()
        
    }
    
    /// Appends the the new site to the siteArray and returns it.
    public static func appendSite(name: String, sites: inout [MOSite]) -> MOSite? {
        let context = PatchData.getContext()
        if let site = NSEntityDescription.insertNewObject(forEntityName: PDStrings.CoreDataKeys.siteEntityName, into: context) as? MOSite {
            site.setName(to: name)
            site.setImageIdentifier(to: name)
            site.setOrder(to: Int16(sites.count))
            sites.append(site)
            PatchData.save()
            return site
        }
        return nil
    }
    
    /// Prints the every site and order (for debugging).
    public func printSites() {
        print("PRINTING SITES")
        print("--------------")
        for site in siteArray {
            print("Order: " + String(site.getOrder()))
            if let n = site.getName() {
                print("Name: " + n)
            } else {
                print("Unnamed")
            }
            print("---------")
        }
        print("*************")
    }
    
    
    // MARK: Private
    
    /// Generates a generic list of MOSites when there are none in store.
    private static func newSiteMOs(into context: NSManagedObjectContext) -> [MOSite] {
        var generatedSiteMOs: [MOSite] = []
        var names = (UserDefaultsController.usingPatches()) ? PDStrings.SiteNames.patchSiteNames : PDStrings.SiteNames.injectionSiteNames
        for i in 0..<names.count {
            if let site = NSEntityDescription.insertNewObject(forEntityName: PDStrings.CoreDataKeys.siteEntityName, into: context) as? MOSite {
                site.setOrder(to: Int16(i))
                site.setName(to: names[i])
                site.setImageIdentifier(to: names[i])
                generatedSiteMOs.append(site)
            }
        }
        PatchData.save()
        return generatedSiteMOs
    }
    
    
    /// For bringing persisted MOSites into memory when starting the app.
    private static func loadSiteMOs(into context: NSManagedObjectContext) -> [MOSite] {
        let fetchRequest = NSFetchRequest<MOSite>(entityName: PDStrings.CoreDataKeys.siteEntityName)
        fetchRequest.propertiesToFetch = PDStrings.CoreDataKeys.sitePropertyNames
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Data Fetch Request Failed")
        }
        return []
    }
    
}
