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
        
        window = .init(frame: UIScreen.main.bounds)
        //window?.rootViewController = TabBarController()
        
        window?.rootViewController = UINavigationController(rootViewController: UserProfileViewController())
        
        window?.makeKeyAndVisible()
        
        return true
    }

}

