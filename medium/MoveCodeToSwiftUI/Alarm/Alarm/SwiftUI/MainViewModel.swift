//
//  MainViewModel.swift
//  Alarm
//
//  Created by Albert Gil Escura on 19/12/21.
//

import Foundation
import Combine

class MainViewModel: ObservableObject {
    @Published var isSwiftUI = false
    @Published var tabBarViewModel: TabBarViewModel
    
    init(
        isSwiftUI: Bool = false,
        tabBarViewModel: TabBarViewModel
    ) {
        self.isSwiftUI = isSwiftUI
        self.tabBarViewModel = tabBarViewModel
    }
    
    func open(url: URL) {
        guard let tab = Tab(rawValue: url.lastPathComponent) else {
            return
        }
        self.tabBarViewModel.selectedTab = tab
    }
}
