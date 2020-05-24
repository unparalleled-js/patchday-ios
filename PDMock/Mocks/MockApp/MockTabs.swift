//
//  MockTabs.swift
//  PDMock
//
//  Created by Juliya Smith on 5/10/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

public class MockTabs: TabReflective {
	
	public init() {}
	
	public var hormonesVC: UIViewController? = nil
	
	public var pillsVC: UIViewController? = nil
	
	public var sitesVC: UIViewController? = nil
	
	public var reflectCallCount = 0
	public func reflect() {
		reflectCallCount += 1
	}
	
	public var reflectHormoneCharacteristicsCount = 0
	public func reflectHormoneCharacteristics() {
		reflectHormoneCharacteristicsCount += 1
	}
	
	public var reflectDuePillBadgeValueCallCount = 0
	public func reflectDuePillBadgeValue() {
		reflectDuePillBadgeValueCallCount += 1
	}
}