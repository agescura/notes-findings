//
//  TabBarViewModel.swift
//  Alarm
//
//  Created by Albert Gil Escura on 19/12/21.
//

import Foundation
import Combine

enum Tab: String {
    case clock, alarms, crono
}

class TabBarViewModel: ObservableObject {
    @Published var selectedTab: Tab
    
    init(selectedTab: Tab) {
        self.selectedTab = selectedTab
    }
}
