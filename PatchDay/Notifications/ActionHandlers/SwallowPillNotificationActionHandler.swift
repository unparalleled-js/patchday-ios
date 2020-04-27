//
//  SwallowPillNotificationActionHandler.swift
//  PatchDay
//
//  Created by Juliya Smith on 10/8/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit


class SwallowPillNotificationActionHandler: SwallowPillNotificationActionHandling {

	let pills: PillScheduling?
	let badge: PDBadgeDelegate

	init(_ pills: PillScheduling?, _ appBadge: PDBadgeDelegate) {
		self.pills = pills
		self.badge = appBadge
	}

	var requestPillNotification: ((_ pill: Swallowable) -> ())?

	func swallow(pillUid: String) {
		if let pills = pills,
			let uuid = UUID(uuidString: pillUid),
			let pill = pills[uuid] {

			pills.swallow(uuid) {
				self.requestPillNotification?(pill)
				self.badge.decrement()
			}
		}
	}
}
