//
//  SceneDelegate.swift
//  TightlyCoupled
//
//  Created by Albert Gil Escura on 17/4/21.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let startingViewController = storyboard.instantiateViewController(identifier: "HomeViewController") as! UINavigationController
        let homeViewController = startingViewController.viewControllers.first as? HomeViewController
        homeViewController?.user = User(name: "Albert")
        window?.rootViewController = startingViewController
        window?.makeKeyAndVisible()
    }
}

