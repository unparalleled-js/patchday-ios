//
// Created by Juliya Smith on 1/4/20.
// Copyright (c) 2020 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

class CoreDataEntitiesLogger {

	private lazy var log = PDLog<CoreDataEntities>()

	func logSites(_ siteMOs: [MOSite]) {
		if siteMOs.count == 0 {
			log.warn("There are no managed sites in the current context")
			return
		}
		for site in siteMOs {
			log.info("MOSite. ID=\(site.id?.uuidString ?? "nil"), Name=\(site.name ?? "nil"), Order=\(site.order)")
		}
	}

	func logPush(_ entity: PDEntity) {
		log.info("Pushing \(entity.rawValue) data in preparation to be saved")
	}

	func logEntityCount(_ count: Int, for entity: PDEntity) {
		log.info("There are \(count) entities of type \(entity.rawValue) in Core Data")
	}

	func logCreate(_ entity: PDEntity, id: String) {
		log.info("Creating new managed \(entity.rawValue) with ID \(id)")
	}

	func logRelateSiteToHormone(siteId: UUID, hormoneId: UUID) {
		log.info("Relating site \(siteId) to hormone \(hormoneId).")
	}

	func logSave(_ entity: PDEntity) {
		log.info("Saving \(entity.rawValue)s changes")
	}

	func warnForNonExistence(_ entity: PDEntity, id: String) {
		log.warn("No managed \(entity.rawValue) exists for ID \(id)")
	}

	func warnForEmptyPush(_ entity: PDEntity) {
		log.warn("Attempted to push \(entity.rawValue) data without any data")
	}

	func errorOnCreation(_ entity: PDEntity) {
		log.error("Failed creating new \(entity.rawValue)")
	}

	func errorOnLoad(_ entity: PDEntity) {
		log.error("Failed to load \(entity.rawValue)s from Core Data")
	}

	func errorOnMissingId(_ entity: PDEntity) {
		log.error("There exists a \(entity.rawValue) that is missing an ID.")
	}

	func logPillMigration() {
		log.info("Migrating pill times to comma-seperated string...")
	}
}