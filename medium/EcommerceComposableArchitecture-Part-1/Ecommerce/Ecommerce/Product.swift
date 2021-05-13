//
//  Product.swift
//  Ecommerce
//
//  Created by Albert Gil Escura on 12/5/21.
//

import Foundation

struct Product: Equatable, Identifiable {
    let id: UUID
    var name: String = "Unknown"
    var items: Int = 0
}
