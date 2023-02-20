//
//  Clipboards.swift
//  Clipboard
//
//  Created by ybw-macbook-pro on 2023/2/20.
//

import Foundation
import CoreData

final class Clipboards: NSManagedObject {
    @NSManaged override var objectID: NSManagedObjectID
    @NSManaged var text: String
}
