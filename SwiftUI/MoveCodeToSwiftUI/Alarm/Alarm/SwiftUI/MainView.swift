//
//  MainView.swift
//  Alarm
//
//  Created by Albert Gil Escura on 19/12/21.
//

import SwiftUI

struct MainView: View {
    @ObservedObject var viewModel: MainViewModel
    
    var body: some View {
        VStack {
            Button(
                self.viewModel.isSwiftUI ? "Use UIKit" : "Use SwiftUI"
            ) {
                self.viewModel.isSwiftUI.toggle()
            }
            if self.viewModel.isSwiftUI {
                TabBarView(viewModel: self.viewModel.tabBarViewModel)
            } else {
                SwiftUIWrapper {
                    TabBarViewController(viewModel: self.viewModel.tabBarViewModel)
                }
            }
        }
        .onOpenURL { self.viewModel.open(url: $0) }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(
            viewModel: .init(
                isSwiftUI: true,
                tabBarViewModel: .init(
                    selectedTab: .alarms,
                    alarmsListViewModel: .init()
                )
            )
        )
    }
}
