//
//  RootTabBarController.swift
//  EpicSchoolHomework
//
//  Created by Vladimir Tezin on 27.05.2022.
//

import UIKit
import Firebase

final class RootTabBarController: UITabBarController {
    
    private var photoItems = [PhotoItem]() {
        didSet{
            photoListVC.photoItemsFetched(photoItems: self.photoItems)
            photoMapVC.photoItemsFetched(photoItems: self.photoItems)
        }
    }
    
    private var firebaseIsConnected: Bool = false {
        didSet{
            print("connected \(firebaseIsConnected)");
            self.tabBar.items?[0].title = firebaseIsConnected ? "онлайн" : "офлайн"
            self.tabBar.items?[0].badgeColor = firebaseIsConnected ? .green : .red        }
    }
    
    private var localPhotosVC = LocalPhotosViewController()
    private var photoListVC = MainScreenViewController()
    private var photoMapVC = AllItemsMapViewController()
    private var userProfileVC = UserProfileViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        configureDatabaseObservers()
        if photoItems.isEmpty {
            refetchPhotoItems()
        }
    }
}

// MARK: -  work with database
extension RootTabBarController {
    fileprivate func configureDatabaseObservers() {
        let connectedRef = Database.database().reference(withPath: ".info/connected")
        
        connectedRef.observe(.value, with: { snapshot in
          if snapshot.value as? Bool ?? false {
              self.firebaseIsConnected = true
              self.refetchPhotoItems()
          } else {
              self.firebaseIsConnected = false
          }
        })
        
        let itemsRef = Database.database().reference().child("photos")
        itemsRef.observe(DataEventType.value, with: { snapshot in
            self.refetchPhotoItems()
        })
    }
    
    private func refetchPhotoItems() {
        DataService.fetchPhotoItems(handler: self.photoItemsFetched)
    }
    
    private func photoItemsFetched(photoItems: [PhotoItem]) {
        self.photoItems = photoItems
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
