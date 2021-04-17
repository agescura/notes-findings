//
//  ProductService.swift
//  TightlyCoupled
//
//  Created by Albert Gil Escura on 17/4/21.
//

import CoreData

class ProductService {
    
    private let context: CommerceContext
    
    init() {
        self.context = CommerceContext()
    }
    
    func getFeaturedProducts(isCustomerPreferred preferred: Bool) -> [Product] {
        let discount = preferred ? 0.95 : 1
        
        let moc = context.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<ProductMO>()
        fetchRequest.entity = NSEntityDescription.entity(forEntityName: "ProductMO", in: moc)
        do {
            return try moc.fetch(fetchRequest)
                .map {
                    Product(id: $0.id,
                            name: $0.name,
                            description: $0.descriptionAttribute,
                            unitPrice: $0.unitPrice * discount,
                            isFeatured: $0.isFeatured)
                }
        } catch {
            return []
        }
    }
    
    func add(product: Product) {
        let moc = context.persistentContainer.viewContext
        
        let newProduct = NSEntityDescription.insertNewObject(forEntityName: "ProductMO", into: moc) as! ProductMO
        newProduct.id = product.id
        newProduct.name = product.name
        newProduct.descriptionAttribute = product.description
        newProduct.unitPrice = product.unitPrice
        newProduct.isFeatured = product.isFeatured
        try? moc.save()
    }
}
