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
                                .init(item: .init(id: .init(), date: .init(), isOn: false)),
                                .init(item: .init(id: .init(), date: .init(), isOn: true)),
                                .init(item: .init(id: .init(), date: .init(), isOn: false)),
                            ]
                        )
                    )
                )
            )
        }
    }
}
