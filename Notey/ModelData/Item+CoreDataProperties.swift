//
//  Item+CoreDataProperties.swift
//  Notey
//
//  Created by Marwan Mekhamer on 01/03/2025.
//
//

import Foundation
import CoreData


extension Item {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Item> {
        return NSFetchRequest<Item>(entityName: "Item")
    }

    @NSManaged public var done: Bool
    @NSManaged public var title: String?
    @NSManaged public var category: Category?

}

extension Item : Identifiable {

}
