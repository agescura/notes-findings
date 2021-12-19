//
//  TabBarView.swift
//  Alarm
//
//  Created by Albert Gil Escura on 19/12/21.
//

import SwiftUI

struct TabBarView: View {
    @ObservedObject var viewModel: TabBarViewModel
    
    var body: some View {
        TabView(
            selection: self.$viewModel.selectedTab
        ) {
            Text("Clock")
                .tabItem { Text("Clock") }
                .tag(Tab.clock)
            
            Text("Alarms")
                .tabItem { Text("Alarms") }
                .tag(Tab.alarms)
            Text("Crono")
                .tabItem { Text("Crono") }
                .tag(Tab.crono)
        }
    }
}

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarView(
            viewModel: .init(
                selectedTab: .alarms
            )
        )
    }
}
