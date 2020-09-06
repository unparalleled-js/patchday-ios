//
// Created by Juliya Smith on 11/30/19.
// Copyright (c) 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

class PillDetailViewModel: CodeBehindDependencies<PillDetailViewModel> {

    let index: Index
    var pill: Swallowable {
        sdk!.pills[index]!
    }
    static let DefaultViewControllerTitle = PDTitleStrings.PillTitle
    var selections = PillAttributes()

    init(_ pillIndex: Index) {
        self.index = pillIndex
        super.init()
    }

    init(_ pillIndex: Index, dependencies: DependenciesProtocol) {
        self.index = pillIndex
        super.init(
            sdk: dependencies.sdk,
            tabs: dependencies.tabs,
            notifications: dependencies.notifications,
            alerts: dependencies.alerts,
            nav: dependencies.nav,
            badge: dependencies.badge
        )
    }

    var title: String {
        pill.isNew ? PDTitleStrings.NewPillTitle : PDTitleStrings.EditPillTitle
    }

    var namePickerStartIndex: Index {
        let name = selections.name ?? pill.name
        return providedPillNameSelection.firstIndex(of: name) ?? 0
    }

    var expirationIntervalStartIndex: Index {
        let interval = selections.expirationInterval ?? pill.expirationInterval
        return PillStrings.Intervals.all.firstIndex(of: interval) ?? 0
    }

    var notifyStartValue: Bool {
        selections.notify ?? pill.notify
    }

    var providedPillNameSelection: [String] {
        PillStrings.DefaultPills + PillStrings.ExtraPills
    }

    var pillSelectionCount: Int {
        PillStrings.DefaultPills.count + PillStrings.ExtraPills.count
    }

    var times: [Time] {
        if let selectedTimes = selections.times {
            return DateFactory.createTimesFromCommaSeparatedString(selectedTimes)
        }
        // Sort, in case Swallowable impl doesn't
        let timeString = PDDateFormatter.convertDatesToCommaSeparatedString(pill.times)
        return DateFactory.createTimesFromCommaSeparatedString(timeString)
    }

    func selectTime(_ time: Time, _ index: Index) {
        var timesToSet = times
        guard index < timesToSet.count && index >= 0 else { return }
        for i in index..<timesToSet.count {
            if timesToSet[i] < time || i == index {
                timesToSet[i] = time
            }
        }
        let timeStrings = PDDateFormatter.convertDatesToCommaSeparatedString(timesToSet)
        selections.times = timeStrings
    }

    func setTimesaday(_ timesaday: Int) {
        guard timesaday != times.count else { return }
        guard timesaday > 0 else { return }
        var timesCopy = times
        if timesaday > times.count {
            // Set new times to have latest time
            for i in times.count..<timesaday {
                timesCopy.append(times[i-1])
            }
        } else {
            for _ in timesaday..<times.count {
                timesCopy.removeLast()
            }
        }
        let newTimeString = PDDateFormatter.convertDatesToCommaSeparatedString(timesCopy)
        selections.times = newTimeString
    }

    func getPickerTimes(timeIndex: Index) -> (start: Time, min: Time?) {
        var startTime = times[timeIndex]
        var minTime: Time?
        if timeIndex > 0 {
            print(self.times)
            minTime = self.times[timeIndex - 1]
        }
        if let minTime = minTime, minTime > startTime {
            startTime = minTime
        }
        return (startTime, minTime)
    }

    func save() {
        notifications?.cancelDuePillNotification(pill)
        sdk?.pills.set(by: pill.id, with: selections)
        notifications?.requestDuePillNotification(pill)
        tabs?.reflectPills()
        selections = PillAttributes()
    }

    func handleIfUnsaved(_ viewController: UIViewController) {
        let save: () -> Void = {
            self.save()
            self.nav?.pop(source: viewController)
        }
        let discard: () -> Void = {
            self.selections = PillAttributes()
            if self.pill.name == PillStrings.NewPill {
                self.sdk?.pills.delete(at: self.index)
            }
            self.nav?.pop(source: viewController)
        }
        if selections.anyAttributeExists || pill.name == PillStrings.NewPill {
            self.alerts?.createUnsavedAlert(
                viewController,
                saveAndContinueHandler: save,
                discardHandler: discard
            ).present()
        } else {
            self.nav?.pop(source: viewController)
        }
    }

    /// Sets the selected name with the name at the given index and optionally returns the name.
    @discardableResult
    func selectNameFromRow(_ row: Index) -> String {
        let name = providedPillNameSelection.tryGet(at: row)
        selections.name = name
        return name ?? ""
    }

    @discardableResult
    func selectExpirationIntervalFromRow(_ row: Index) -> String {
        let interval = PillStrings.Intervals.all.tryGet(at: row)
        selections.expirationInterval = interval
        return interval ?? ""
    }
}
