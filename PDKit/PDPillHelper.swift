//
//  PillsDelegate.swift
//  PDKit
//
//  Created by Juliya Smith on 6/20/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

public typealias Stamp = Date
public typealias Stamps = [Stamp?]?

public struct PillAttributes {
    public var name: String?
    public var timesaday: Int?
    public var time1: Time?
    public var time2: Time?
    public var notify: Bool?
    public var timesTakenToday: Int?
    public var lastTaken: Date?
    public var id: UUID?
    public init(name: String?, timesaday: Int?,
                time1: Time?, time2: Time?,
                notify: Bool?, timesTakenToday: Int?,
                lastTaken: Date?, id: UUID?) {
        self.name = name
        self.timesaday = timesaday
        self.time1 = time1
        self.time2 = time2
        self.notify = notify
        self.timesTakenToday = timesTakenToday
        self.lastTaken = lastTaken
        self.id = id
    }
    // Default
    public init() {
        self.name = PDStrings.PlaceholderStrings.new_pill
        self.timesaday = 1
        self.time1 = Time()
        self.time2 = Time()
        self.notify = true
        self.timesTakenToday = 0
        self.lastTaken = Date()
        self.id = UUID()
    }
}

public class PDPillHelper: NSObject {
    
    /// Return the next time the pill is due.
    public static func nextDueDate(timesTakenToday: Int, timesaday: Int, times: [NSDate?]) -> Date? {
        if times.count > 0, let time1 = times[0] as Time? {
            if timesaday == 1 {
                if timesTakenToday == 0 {
                    return PDDateHelper.getDate(on: Date(), at: time1)
                }
                // Take tomorrow
                else if let todayTime = PDDateHelper.getDate(on: Date(), at: time1) {
                    return PDDateHelper.getDate(at: todayTime, daysToAdd: 1)
                }
            }
            // When timesaday == 2
            else if times.count >= 1, let time2 = times[1] as Time? {
                if timesTakenToday == 0 {
                    let minTime = min(time1, time2)
                    return PDDateHelper.getDate(on: Date(), at: minTime)
                }
                else if timesTakenToday == 1 {
                    let maxTime = max(time1, time2)
                    return PDDateHelper.getDate(on: Date(), at: maxTime)
                }
                else {
                    let minTime = min(time1, time2)
                    if let todayTime = PDDateHelper.getDate(on: Date(), at: minTime) {
                        return PDDateHelper.getDate(at: todayTime, daysToAdd: 1)
                    }
                }
            }
        }
        return nil
    }
    
    public static func isDue(_ dueDate: Date) -> Bool {
        return Date() > dueDate
    }
    
    public static func isDone(timesTakenToday: Int, timesaday: Int) -> Bool {
        return timesTakenToday >= timesaday
    }
    
    public static func getPill(in pillArray: [MOPill], for id: UUID) -> MOPill? {
        if let i = pillArray.map({
            (pill: MOPill) -> UUID? in
            return pill.getID()
        }).index(of: id) {
            return pillArray[i]
        }
        return nil
    }
    
    /// Maps MOPills to their next relevant due times.
    public static func getNextPillDueDates(from pills: [MOPill]) -> [Date] {
        return pills.map({
            (pill: MOPill) -> Time? in
            return pill.getDueDate()
        }).filter() {
            $0 != nil
            }.map({
                (time: Time?) -> Time in
                return time!
            })
    }

}