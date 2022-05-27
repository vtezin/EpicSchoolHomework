//
//  RootTabBarController.swift
//  EpicSchoolHomework
//
//  Created by Vladimir Tezin on 27.05.2022.
//

import UIKit

class RootTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        UITabBar.appearance().barTintColor = .systemBackground
        tabBar.tintColor = .label
        configure()
    }
}

// MARK: -  Configure
extension RootTabBarController {
    
    fileprivate func configure() {
        setupVCs()
    }
    
    fileprivate func createNavController(for rootViewController: UIViewController,
                                         title: String,
                                         image: UIImage) -> UIViewController {
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.tabBarItem.title = title
        navController.tabBarItem.image = image
        
        return navController
    }
    
    fileprivate func setupVCs() {
          viewControllers = [
              createNavController(for: MainScreenViewController(), title: NSLocalizedString("Фотки", comment: ""), image: UIImage(systemName: "photo.on.rectangle.angled")!),
              createNavController(for: AllItemsMapViewController(), title: NSLocalizedString("Карта", comment: ""), image: UIImage(systemName: "map")!),
              createNavController(for: UserProfileViewController(), title: NSLocalizedString("Профиль", comment: ""), image: UIImage(systemName: "person")!)
          ]
      }
    
}
