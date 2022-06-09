//
//  DataController.swift
//  EpicSchoolHomework
//
//  Created by Vladimir Tezin on 02.05.2022.
//

import Foundation
import Combine

//TODO: delete it
final class DataService: NSObject {
    
    @Published private(set) var photoItems = [PhotoItem]()
    
    static func fetchPhotoItems(handler: @escaping ([PhotoItem]) -> Void) {
        if FireBaseService.isConnected {
            //FireBaseService.fetchPhotoItems(handler: handler)
        } else {
            let photoItems = PhotoItemRealm.fetchPhotoItems()
            handler(photoItems)
        }
    }
}
