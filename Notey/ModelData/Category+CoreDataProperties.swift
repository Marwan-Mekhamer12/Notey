//
//  Category+CoreDataProperties.swift
//  Notey
//
//  Created by Marwan Mekhamer on 01/03/2025.
//
//

import Foundation
import CoreData


extension Category {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Category> {
        return NSFetchRequest<Category>(entityName: "Category")
    }

    @NSManaged public var done: Bool
    @NSManaged public var title: String?
    @NSManaged public var category: NSSet?

}

// MARK: Generated accessors for category
extension Category {

    @objc(addCategoryObject:)
    @NSManaged public func addToCategory(_ value: Item)

    @objc(removeCategoryObject:)
    @NSManaged public func removeFromCategory(_ value: Item)

    @objc(addCategory:)
    @NSManaged public func addToCategory(_ values: NSSet)

    @objc(removeCategory:)
    @NSManaged public func removeFromCategory(_ values: NSSet)

}

extension Category : Identifiable {

}
