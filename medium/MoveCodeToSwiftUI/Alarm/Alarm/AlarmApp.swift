//
//  AlarmApp.swift
//  Alarm
//
//  Created by Albert Gil Escura on 19/12/21.
//

import SwiftUI

@main
struct AlarmApp: App {
    var body: some Scene {
        WindowGroup {
            MainView(
                viewModel: .init(
                    isSwiftUI: true,
                    tabBarViewModel: .init(
                        selectedTab: .alarms,
                        alarmsListViewModel: .init(
                            items: [
                                .init(id: .init(), date: .init(), isOn: false),
                                .init(id: .init(), date: .init(), isOn: true),
                                .init(id: .init(), date: .init(), isOn: false)
                            ]
                        )
                    )
                )
            )
        }
    }
}
