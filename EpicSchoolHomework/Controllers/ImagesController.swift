//
//  ImagesController.swift
//  EpicSchoolHomework
//
//  Created by Vladimir Tezin on 02.05.2022.
//

import Foundation
import UIKit

class ImagesController {
    static var loadedImagesCash = [String: UIImage]()
    
    static func fetchImageForPhotoItem(photoItem: PhotoItem, completion: @escaping (UIImage?) -> Void) {
        var foundedImage: UIImage? = nil
        
        //1. try get image from item and from item cash
        if let image = photoItem.image {
            foundedImage = image
        } else if let image = ImagesController.loadedImagesCash[photoItem.imageURL] {
            foundedImage = image
        }
        
        if let image = foundedImage {
            DispatchQueue.main.async {
                completion(image)
            }
            return
        }
        
        //2. try get image from firebase
        FireBaseController.getImage(imageName: photoItem.imageURL, completion: completion)
    }    
}
