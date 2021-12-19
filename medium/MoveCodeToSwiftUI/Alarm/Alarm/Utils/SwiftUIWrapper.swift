//
//  SwiftUIWrapper.swift
//  Alarm
//
//  Created by Albert Gil Escura on 19/12/21.
//

import SwiftUI

struct SwiftUIWrapper: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = UIViewController
    
    let viewController: () -> UIViewController
    
    func makeUIViewController(
        context: Context
    ) -> UIViewController {
        self.viewController()
    }
    
    func updateUIViewController(
        _ uiViewController: UIViewController,
        context: Context
    ) {}
}
