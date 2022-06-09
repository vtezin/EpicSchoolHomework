//
//  RootTabBarController.swift
//  EpicSchoolHomework
//
//  Created by Vladimir Tezin on 27.05.2022.
//

import UIKit
import Firebase
import Combine

final class RootTabBarController: UITabBarController {
    
    private var localPhotosVC = LocalPhotosViewController()
    private var photoListVC = PhotoItemListViewController()
    private var photoMapVC = AllItemsMapViewController()
    private var userProfileVC = UserProfileViewController()
    
    private var firebaseIsConnectedSubscription: AnyCancellable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        firebaseIsConnectedSubscription = appState.$firebaseIsConnected.sink(receiveValue: {[weak self] firebaseIsConnected in
            self?.tabBar.items?[0].title = firebaseIsConnected ? "онлайн" : "офлайн"
            self?.tabBar.items?[0].badgeColor = firebaseIsConnected ? .green : .red
        })
    }
}

// MARK: -  Configure
extension RootTabBarController {
    
    fileprivate func configure() {
        view.backgroundColor = .systemBackground
        UITabBar.appearance().barTintColor = .systemBackground
        tabBar.tintColor = .label
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
            createNavController(for: photoListVC, title: NSLocalizedString("Лента", comment: ""), image: UIImage(systemName: "photo.on.rectangle.angled")!),
              createNavController(for: photoMapVC, title: NSLocalizedString("Карта", comment: ""), image: UIImage(systemName: "map")!),
            createNavController(for: localPhotosVC, title: NSLocalizedString("Черновики", comment: ""), image: UIImage(systemName: "tray.full")!),
              createNavController(for: userProfileVC, title: NSLocalizedString("Профиль", comment: ""), image: UIImage(systemName: "person")!)
          ]
      }
}
