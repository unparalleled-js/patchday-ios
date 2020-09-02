//
//  DateFactory.swift
//  PDKit
//
//  Created by Juliya Smith on 6/20/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

public class DateFactory: NSObject {

    private static var calendar = Calendar.current

    public static func createTodayDate(at time: Time) -> Date? {
        createDate(on: Date(), at: time)
    }

    /// Creates a new Date from given Date at the given Time.
    public static func createDate(on date: Date, at time: Time) -> Date? {
        let components = DateComponents(
            calendar: calendar,
            timeZone: calendar.timeZone,
            year: calendar.component(.year, from: date),
            month: calendar.component(.month, from: date),
            day: calendar.component(.day, from: date),
            hour: calendar.component(.hour, from: time),
            minute: calendar.component(.minute, from: time)
        )
        return calendar.date(from: components)
    }

    /// Create a Date by adding days from right now.
    public static func createDate(daysFromNow: Int) -> Date? {
        createDate(at: Date(), daysFromToday: daysFromNow)
    }

    /// Creates a Date at the given time calculated by adding days from today.
    public static func createDate(at time: Time, daysFromToday: Int) -> Date? {
        var componentsToAdd = DateComponents()
        componentsToAdd.day = daysFromToday
        if let newDate = calendar.date(byAdding: componentsToAdd, to: Date()) {
            return createDate(on: newDate, at: time)
        }
        return nil
    }

    public static func createDate(byAddingMonths months: Int, to date: Date) -> Date? {
        calendar.date(byAdding: .month, value: months, to: date)
    }

    /// Gives the future date from the given one based on the given interval string.
    public static func createDate(byAddingHours hours: Int, to date: Date) -> Date? {
        calendar.date(byAdding: .hour, value: hours, to: date)
    }

    public static func createDate(byAddingMinutes minutes: Int, to date: Date) -> Date? {
        calendar.date(byAdding: .minute, value: minutes, to: date)
    }

    public static func createDate(byAddingSeconds seconds: Int, to date: Date) -> Date? {
        calendar.date(byAdding: .second, value: seconds, to: date)
    }

    public static func createExpirationDate(
        expirationInterval: ExpirationIntervalUD, to date: Date
    ) -> Date? {
        createDate(byAddingHours: expirationInterval.hours, to: date)
    }

    public static func createTimesFromCommaSeparatedString(_ dateString: String) -> [Time] {
        let formatter = DateFormatterFactory.createInternalTimeFormatter()
        let dates = dateString.split(separator: ",").map {
            formatter.date(from: String($0))
        }.filter { $0 != nil }
        return dates as! [Time]
    }

    /// Creates a time interval by adding the given hours to the given date.
    public static func createTimeInterval(fromAddingHours hours: Int, to date: Date) -> TimeInterval? {
        guard !date.isDefault(), let dateWithAddedHours = createDate(byAddingHours: hours, to: date) else {
            return nil
        }
        // Find start and end between date and now (handling negative hours)
        var range = [Date(), dateWithAddedHours]
        range.sort()
        let interval = DateInterval(start: range[0], end: range[1]).duration
        return range[1] == dateWithAddedHours ? interval : -interval
    }

    public static func createDateBeforeAtEightPM(of date: Date) -> Date? {
        guard let eightPM = createEightPM(of: date) else { return nil }
        return createDayBefore(eightPM)
    }

    public static func createDefaultDate() -> Date {
        Date(timeIntervalSince1970: 0)
    }

    private static func createEightPM(of date: Date) -> Date? {
        calendar.date(bySettingHour: 20, minute: 0, second: 0, of: date)
    }

    private static func createDayBefore(_ date: Date) -> Date? {
        calendar.date(byAdding: .day, value: -1, to: date)
    }
}
