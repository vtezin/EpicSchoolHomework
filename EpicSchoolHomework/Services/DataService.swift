//
//  DataController.swift
//  EpicSchoolHomework
//
//  Created by Vladimir Tezin on 02.05.2022.
//

import Foundation

final class DataService {
    static func fetchPhotoItems(handler: @escaping ([PhotoItem]) -> Void) {
        if FireBaseService.isConnected {
            FireBaseService.fetchPhotoItems(handler: handler)
        } else {
            let photoItems = RealmService.fetchItems()
            handler(photoItems)
        }
    }
}
