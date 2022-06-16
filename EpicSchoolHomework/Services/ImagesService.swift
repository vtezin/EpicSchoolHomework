//
//  ImagesController.swift
//  EpicSchoolHomework
//
//  Created by Vladimir Tezin on 02.05.2022.
//

import UIKit

final class ImagesService {
    static var loadedImagesCash = [String: UIImage]()
    
    static func fetchImageForPhotoItem(photoItem: PhotoItem, completion: @escaping (UIImage?) -> Void) {
        var foundedImage: UIImage? = nil
        
        //1. try get image from item and from item cash
        if let image = photoItem.image {
            foundedImage = image
        } else if let image = ImagesService.loadedImagesCash[photoItem.imageURL] {
            foundedImage = image
        }
        
        if let image = foundedImage {
            DispatchQueue.main.async {
                completion(image)
            }
            return
        }
        
        //2. try get image from Realm
        if let photoItemRealm = PhotoItemRealm.findItem(photoItem: photoItem) {
            DispatchQueue.main.async {
                completion(UIImage(data: photoItemRealm.imageData))
            }
            return
        }
        
        //2. try get image from firebase
        FireBaseService.getImage(imageName: photoItem.imageURL, completion: completion)
    }
    
    static func getLocalImageForPhotoItem(photoItem: PhotoItem) -> UIImage? {
        if let image = loadedImagesCash[photoItem.imageURL] {
            return image
        }
        
        if let image = PhotoItemRealm.fetchImageForItem(itemID: photoItem.id) {
            return image
        }
        
        return nil
    }
    
}
