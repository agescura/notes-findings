//
//  CounterView.swift
//  CounterView
//
//  Created by Albert Gil Escura on 25/5/21.
//

import SwiftUI
import ComposableArchitecture

public struct CounterView: View {
    private let store: Store<CounterState, CounterAction>

    public init(
        store: Store<CounterState, CounterAction>
    ) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(self.store) { viewStore in
            HStack {
                Text("Cheese")
                Spacer()
                HStack {
                    Button(
                        action: { viewStore.send(.decrementTapped) },
                        label: { Text("-") }
                    )
                    .buttonStyle(PlainButtonStyle())
                    Text("\(viewStore.counter)")
                    Button(
                        action: { viewStore.send(.incrementTapped) },
                        label: { Text("+") }
                    )
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
}

struct CounterView_Previews: PreviewProvider {
    static var previews: some View {
        CounterView(
            store: Store(
                initialState: CounterState(),
                reducer: reducerCounter,
                environment: ()
            )
        )
    }
}

