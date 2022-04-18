//
//  TabBarController.swift
//  EpicSchoolHomework
//
//  Created by Vladimir Tezin on 17.04.2022.
//

import UIKit

final class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        configureApperance()
        
        viewControllers = [createNavController(for: MainScreenViewController(), title: NSLocalizedString("Фотки", comment: ""), imageName: "text.below.photo"),
                           createNavController(for: NewUserViewController(), title: NSLocalizedString("Профиль", comment: ""), imageName: "person")
        ]
        
    }
    
}

// MARK: -  Functions
extension TabBarController {
    
    func configureApperance() {
        view.backgroundColor = .systemBackground
        UITabBar.appearance().barTintColor = .systemBackground
        tabBar.tintColor = .label
    }
    
    func createNavController(for rootViewController: UIViewController,
                             title: String,
                             imageName: String) -> UIViewController {
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.tabBarItem.title = title
        if let uiImage = UIImage(systemName: imageName) {
            navController.tabBarItem.image = uiImage
        }
        navController.navigationBar.prefersLargeTitles = true
        rootViewController.navigationItem.title = title
        return navController
    }
    
}