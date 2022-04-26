//
//  FirebaseDataProvider.swift
//  EpicSchoolHomework
//
//  Created by Vladimir Tezin on 18.04.2022.
//

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseStorage
import UIKit

class FireBaseDataProvider {
    
    static let shared = FireBaseDataProvider()
    static var loadedImages = [String: UIImage]()
    
    func fetchPhotoItems(handler: @escaping ([PhotoItem]) -> Void) {
        var photoItems = [PhotoItem]()
        
        let ref = Database.database().reference()
        ref.child("photos").observeSingleEvent(of: .value, with: { snapshot in
            let photos = snapshot.value as! NSDictionary
            for photo in photos {
                let photoValue = photo.value as! NSDictionary
                
                let author = photoValue["author"] as? String ?? ""
                let description = photoValue["description"] as? String ?? ""
                let imageURL = photoValue["imageURL"] as? String ?? ""
                let likesCount = photoValue["likesCount"] as? Int ?? 0
                let liked = photoValue["liked"] as! Bool
                
                var comments = [PhotoItem.Comment]()
                
                //let commentsValueArray = photoValue["comments"] as! NSArray
                let commentsValueArray = photoValue["comments"] as! NSDictionary
                
                for comment in commentsValueArray {
                    if let comment = comment.value as? NSDictionary {
                        comments.append(PhotoItem.Comment(author: comment["author"] as! String,
                                                          text: comment["text"] as! String))
                    }
                }
                
                let photoItem = PhotoItem(id: photo.key as! String,
                                          image: nil,
                                          imageURL: imageURL,
                                          author: author,
                                          description: description,
                                          likesCount: likesCount,
                                          liked: liked,
                                          comments: comments)
                
                
                photoItems.append(photoItem)
            }
            handler(photoItems)
        }) { error in
            print(error.localizedDescription)
        }
        
    }
    
    static func getImage(imageName: String, completion: @escaping (UIImage?) -> Void) {
        
        if let loadedImage = loadedImages[imageName] {
            DispatchQueue.main.async {
                completion(loadedImage)
            }
        }
        
        let storageRef = Storage.storage().reference()
        let imageRef = storageRef.child(imageName)
        
        imageRef.getData(maxSize: 1000 * 1024 * 1024) { data, error in
            if let error = error {
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    completion(nil)
                }
            } else {
                let result = UIImage(data: data!)
                loadedImages[imageName] = result
                DispatchQueue.main.async {
                    completion(result)
                }
            }
        }
    }

    
    func updateLikesInfo(photoItem: PhotoItem) {
        let ref = Database.database().reference()
        let childUpdates = ["/photos/\(photoItem.id)/liked": photoItem.liked,
                            "/photos/\(photoItem.id)/likesCount": photoItem.likesCount] as [String : Any]
        ref.updateChildValues(childUpdates)
    }
    
    func addComment(photoItem: PhotoItem, comment: PhotoItem.Comment) {
        let ref = Database.database().reference()
        guard let key = ref.child("/photos/\(photoItem.id)/comments").childByAutoId().key else {
            return
        }
        let post = ["author": comment.author,
                    "text": comment.text]
        let childUpdates = ["/photos/\(photoItem.id)/comments/\(key)": post]
        ref.updateChildValues(childUpdates)
    }
}
