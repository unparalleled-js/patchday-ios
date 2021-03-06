//
//  ApplyHormoneNotificationActionHandler.swift
//  PatchDay
//
//  Created by Juliya Smith on 11/7/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

class HormoneNotificationActionHandler: HormoneNotificationActionHandling {

	private let sdk: PatchDataSDK?
	private let badge: PDBadgeDelegate

	convenience init(sdk: PatchDataSDK?) {
		self.init(sdk: sdk, appBadge: PDBadge())
	}

	init(sdk: PatchDataSDK?, appBadge: PDBadgeDelegate) {
		self.sdk = sdk
		self.badge = appBadge
	}

	func handleHormone(id: String) {
		guard let id = UUID(uuidString: id) else { return }
		guard let suggestedSite = sdk?.sites.suggested else { return }
		sdk?.hormones.set(by: id, date: Date(), site: suggestedSite, incrementSiteIndex: true)
		badge.decrement()
	}
}
