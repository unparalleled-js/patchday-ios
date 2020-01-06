//
//  PDCoreDataDelegate.swift
//  PDKit
//
//  Created by Juliya Smith on 9/20/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation


public protocol PDCoreDataDelegate {
    func save(saverName: String)
    func getManagedObjects(entity: PDEntity) -> [Any]?
    func insert(_ entity: PDEntity) -> Any?
    func nuke()
    func tryDelete(_ managedObject: Any)
}