//
//  EcommerceApp.swift
//  Ecommerce
//
//  Created by Albert Gil Escura on 12/5/21.
//

import SwiftUI

@main
struct EcommerceApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(
                store: Store(initialState: AppState(products: [
                    Product(id: UUID(), name: "Producto 1", items: 0),
                    Product(id: UUID(), name: "Producto 2", items: 0),
                    Product(id: UUID(), name: "Producto 3", items: 0),
                ]),
                reducer: appReducer,
                environment: AppEnvironment())
            )
        }
    }
}
