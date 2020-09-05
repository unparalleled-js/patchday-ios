//
//  DateIntegrationTests.swift
//  PDKitTests
//
//  Created by Juliya Smith on 9/4/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import XCTest
import Foundation

@testable
import PDKit

class DateIntegrationTests: XCTestCase {

    func testInternalTimes_string() {
        let timeString = "12:51:30"
        let timeArray = DateFactory.createTimesFromCommaSeparatedString(timeString)
        let timeStringBack = PDDateFormatter.convertDatesToCommaSeparatedString(timeArray)
        XCTAssertEqual(timeString, timeStringBack)
    }

    func testInternalTimes_date() {
        let timeString = "12:51:30"
        let time = DateFactory.createTimesFromCommaSeparatedString(timeString)[0]
        let timeStringBack = PDDateFormatter.convertDatesToCommaSeparatedString([time])
        let timeAgain = DateFactory.createTimesFromCommaSeparatedString(timeStringBack)[0]
        XCTAssertEqual(time, timeAgain)
    }

    func testInternalTimes_pm() {
        let timeString = "17:51:30"
        let timeArray = DateFactory.createTimesFromCommaSeparatedString(timeString)
        let timeStringBack = PDDateFormatter.convertDatesToCommaSeparatedString(timeArray)
        XCTAssertEqual(timeString, timeStringBack)
    }
}