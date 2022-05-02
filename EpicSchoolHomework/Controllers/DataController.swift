//
//  DataController.swift
//  EpicSchoolHomework
//
//  Created by Vladimir Tezin on 02.05.2022.
//

import Foundation

final class DataController {
    static func fetchPhotoItems(handler: @escaping ([PhotoItem]) -> Void) {
        if FireBaseController.isConnected {
            FireBaseController.fetchPhotoItems(handler: handler)
        } else {
            let photoItems = RealmController.fetchItems()
            handler(photoItems)
        }
    }
}
