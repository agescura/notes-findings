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
        
        // deeplink:///alarms/add?isOn=true&date=2015-01-01T00:00:00.000Z
        
        if components.count == 3 {
            guard let tab = Tab(rawValue: components[1]) else { return }
            self.tabBarViewModel.selectedTab = tab
            
            var date = Date()
            var isOn = false
            
            if components.last == "add" {
                if let params = URLComponents(string: url.absoluteString)?.queryItems {
                    if let paramIsOn = params.first(where: { $0.name == "isOn"})?.value {
                        if paramIsOn.lowercased() == "true" {
                            isOn = true
                        }
                    }
                    if let paramDate = params.first(where: { $0.name == "date"})?.value {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
                        date = formatter.date(from: paramDate) ?? Date()
                    }
                }
                self.tabBarViewModel.alarmsListViewModel.route = .add(.init(alarmItem: .init(id: .init(), date: date, isOn: isOn)))
            }
        }
        
        if components.count == 4 {
            guard let tab = Tab(rawValue: components[1]) else { return }
            self.tabBarViewModel.selectedTab = tab
            
            let uuid = components[2]
            guard let item = self.tabBarViewModel.alarmsListViewModel.items.first(where: { $0.id.uuidString == uuid }) else { return }
            
            // deeplink:///alarms/:id/delete
            
            if components.last == "delete" {
                self.tabBarViewModel.alarmsListViewModel.route = .items(id: item.id, route: .deleteAlert)
            }
            
            // deeplink:///alarms/:id/toggle
            
            if components.last == "toggle" {
                self.tabBarViewModel.alarmsListViewModel.route = .items(id: item.id, route: .toggleConfirmationDialog)
            }
        }
    }
}

