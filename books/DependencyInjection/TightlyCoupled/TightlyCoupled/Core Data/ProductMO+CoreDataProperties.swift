//
//  ProductMO+CoreDataProperties.swift
//  TightlyCoupled
//
//  Created by Albert Gil Escura on 17/4/21.
//
//

import Foundation
import CoreData


extension ProductMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ProductMO> {
        return NSFetchRequest<ProductMO>(entityName: "ProductMO")
    }

    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var descriptionAttribute: String
    @NSManaged public var unitPrice: Double
    @NSManaged public var isFeatured: Bool

}

extension ProductMO : Identifiable {

}
