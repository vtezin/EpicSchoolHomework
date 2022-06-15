//
//  AppState.swift
//  EpicSchoolHomework
//
//  Created by Vladimir Tezin on 04.06.2022.
//

import Combine
import UIKit
import Firebase

final class AppState: NSObject {
    @Published var photoItems: [PhotoItem]
    @Published var firebaseIsConnected: Bool = false
    
    var currentUserName: String {
        FireBaseService.currentUserName
    }
    
    let locationService = LocationService()
    let firebaseService = FireBaseService()
    
    override init() {
        photoItems = PhotoItemRealm.fetchPhotoItems()
        super.init()
        firebaseService.delegate = self
        configureDatabaseObservers() 
    }
}

extension AppState {
    private func configureDatabaseObservers() {
        let connectedRef = Database.database().reference(withPath: ".info/connected")
        
        connectedRef.observe(.value, with: { snapshot in
          if snapshot.value as? Bool ?? false {
              self.firebaseIsConnected = true
              self.firebaseService.fetchPhotoItemsWithPhotos()
          } else {
              self.firebaseIsConnected = false
          }
        })
        
        let itemsRef = Database.database().reference().child("photos")
        itemsRef.observe(DataEventType.value, with: { snapshot in
            self.firebaseService.fetchPhotoItemsWithPhotos()
        })
    }
}

// MARK: -  FireBaseServiceDelegate
extension AppState: FireBaseServiceDelegate {
    func photoItemsFetched(photoItems: [PhotoItem]) {
        self.photoItems = photoItems
    }
    
    func photoItemImageFetched(itemID: String, image: UIImage) {
        guard let changedItem = photoItems.first(where: {$0.id == itemID}),
        let changedItemIndex = photoItems.firstIndex(where: {$0.id == itemID}) else {return}
        guard changedItem.image == nil else {
            return
        }
        
        var newItem = changedItem
        newItem.setImage(image: image)

        photoItems[changedItemIndex] = newItem
        
        PhotoItemRealm.saveItem(photoItem: newItem)
        //print("photoItemImageFetched \(changedItem.description)")
    }
}

// MARK: -  global function
func printDebug(_ string: String) {
    print("debug | " + string)
}
