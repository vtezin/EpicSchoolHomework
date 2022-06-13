//
//  RealmController.swift
//  EpicSchoolHomework
//
//  Created by Vladimir Tezin on 30.04.2022.
//

import UIKit
import RealmSwift

final class RealmService {
    static let config = Realm.Configuration(schemaVersion: 8)
    
    static func printRealmLocation(){
        print("Realm is located at:", try! Realm(configuration: RealmService.config).configuration.fileURL!)
    }
}
