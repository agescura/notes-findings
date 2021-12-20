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
        let components = url.pathComponents
        
        if components.count == 2 {
            // deeplink:///alarms
            guard let tab = Tab(rawValue: url.lastPathComponent) else {
                return
            }
            self.tabBarViewModel.selectedTab = tab
        }
        
        // deeplink:///alarms/:id/delete
        
        if components.count == 4 {
            guard let tab = Tab(rawValue: components[1]) else { return }
            self.tabBarViewModel.selectedTab = tab
            
            if components.last == "delete" {
                let uuid = components[2]
                guard let item = self.tabBarViewModel.alarmsListViewModel.items.first(where: { $0.id.uuidString == uuid }) else { return }
                
                self.tabBarViewModel.alarmsListViewModel.route = .deleteAlert(item)
            }
        }
    }
}
