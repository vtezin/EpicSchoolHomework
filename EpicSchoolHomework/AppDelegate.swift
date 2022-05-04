//
//  AppDelegate.swift
//  EpicSchoolHomework
//
//  Created by Vladimir Tezin on 18.03.2022.
//

import UIKit
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        
        let connectedRef = Database.database().reference(withPath: ".info/connected")
        connectedRef.observe(.value, with: { snapshot in
          if snapshot.value as? Bool ?? false {
              FireBaseService.isConnected = true
          } else {
              FireBaseService.isConnected = false
          }
        })
        
        window = .init(frame: UIScreen.main.bounds)
        
        window?.rootViewController = UINavigationController(rootViewController: UserProfileViewController())
        
        window?.makeKeyAndVisible()
        
        return true
    }

}

