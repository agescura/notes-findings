//
//  FormsApp.swift
//  Forms
//
//  Created by Albert Gil Escura on 25/5/21.
//

import SwiftUI
import ComposableArchitecture

@main
struct FormsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(
                store: Store(
                    initialState: AppState(),
                    reducer: appReducer,
                    environment: ()
                )
            )
        }
    }
}
