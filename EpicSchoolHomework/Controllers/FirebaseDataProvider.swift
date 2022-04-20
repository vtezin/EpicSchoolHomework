//
//  FirebaseDataProvider.swift
//  EpicSchoolHomework
//
//  Created by Vladimir Tezin on 18.04.2022.
//

import Foundation
import Firebase
import FirebaseDatabase

class FireBaseDataProvider {
    
    static let shared = FireBaseDataProvider()
    
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
                
                let commentsValueArray = photoValue["comments"] as! NSArray
                
                for comment in commentsValueArray {
                    if let comment = comment as? NSDictionary {
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
    
    func updateLikesInfo(photoItem: PhotoItem) {
        let ref = Database.database().reference()
        let childUpdates = ["/photos/\(photoItem.id)/liked": photoItem.liked,
                            "/photos/\(photoItem.id)/likesCount": photoItem.likesCount] as [String : Any]
        ref.updateChildValues(childUpdates)
    }
    
}
