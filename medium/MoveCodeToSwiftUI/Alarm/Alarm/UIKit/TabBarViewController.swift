//
//  TabBarViewController.swift
//  Alarm
//
//  Created by Albert Gil Escura on 19/12/21.
//

import UIKit
import Combine

class TabBarViewController: UITabBarController {
    let viewModel: TabBarViewModel
    private var cancellables: Set<AnyCancellable> = []
    
    init(viewModel: TabBarViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let clockLabel = UILabel()
        clockLabel.text = "Clock"
        clockLabel.sizeToFit()
        let clock = UIViewController()
        clock.tabBarItem.title = "Clock"
        clock.view.addSubview(clockLabel)
        clockLabel.center = clock.view.center
        
        let alarms = AlarmsListViewController(
          viewModel: self.viewModel.alarmsListViewModel
        )
        let navigationAlarms = UINavigationController(rootViewController: alarms)
        navigationAlarms.tabBarItem.title = "Alarms"
        
        let cronoLabel = UILabel()
        cronoLabel.text = "Crono"
        cronoLabel.sizeToFit()
        let crono = UIViewController()
        crono.tabBarItem.title = "Crono"
        crono.view.addSubview(cronoLabel)
        cronoLabel.center = crono.view.center
        
        self.setViewControllers([clock, navigationAlarms, crono], animated: false)
        
        self.viewModel.$selectedTab
            .sink { [unowned self] tab in
                switch tab {
                case .clock:
                    self.selectedIndex = 0
                case .alarms:
                    self.selectedIndex = 1
                case .crono:
                    self.selectedIndex = 2
                }
            }
            .store(in: &self.cancellables)
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let index = tabBar.items?.firstIndex(of: item) else {
            return
        }
        
        switch index {
        case 0:
            self.viewModel.selectedTab = .clock
        case 1:
            self.viewModel.selectedTab = .alarms
        case 2:
            self.viewModel.selectedTab = .crono
        default:
            break
        }
    }
}

import SwiftUI

struct TabBarViewController_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIWrapper {
            TabBarViewController(
                viewModel: .init(
                    selectedTab: .alarms,
                    alarmsListViewModel: .init()
                )
            )
        }
    }
}
