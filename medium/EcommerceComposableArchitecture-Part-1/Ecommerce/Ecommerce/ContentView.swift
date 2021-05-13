//
//  ContentView.swift
//  Ecommerce
//
//  Created by Albert Gil Escura on 12/5/21.
//

import SwiftUI
import ComposableArchitecture

struct ContentView: View {
    let store: Store<AppState, AppAction>
    
    var body: some View {
        NavigationView {
            WithViewStore(store) { viewStore in
                List {
                    ForEach(Array(viewStore.products.enumerated()), id: \.element.id) { index, product in
                        HStack {
                            Text(product.name)
                            Spacer()
                            Button(action: {
                                viewStore.send(.minusItem(index: index))
                            }, label: {
                                Image(systemName: "minus.square")
                            })
                            .buttonStyle(PlainButtonStyle())
                            Text("\(product.items)")
                            Button(action: {
                                viewStore.send(.addItem(index: index))
                            }, label: {
                                Image(systemName: "plus.app")
                            })
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .navigationBarTitle("Productos")
            }
        }
    }
}











struct AppState: Equatable {
    var products: [Product] = []
}

enum AppAction {
    case addItem(index: Int)
    case minusItem(index: Int)
}

struct AppEnvironment {}

let appReducer = Reducer<AppState, AppAction, AppEnvironment> { state, action, environment in
    switch action {
    case .addItem(index: let index):
        state.products[index].items += 1
        return .none
    case .minusItem(index: let index):
        state.products[index].items = max(state.products[index].items - 1, 0)
        return .none
    }
}
.debug()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
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
