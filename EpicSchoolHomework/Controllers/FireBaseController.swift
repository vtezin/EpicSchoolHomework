//
//  FireBaseController.swift
//  EpicSchoolHomework
//
//  Created by Vladimir Tezin on 18.04.2022.
//

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseStorage
import UIKit

class FireBaseController {
    static var loadedImagesCash = [String: UIImage]()
    static var currentUserName: String {
        if let curUser = Auth.auth().currentUser {
            return curUser.email ?? "??"
        } else {
           return "??"
        }
    }
    
    static func fetchPhotoItems(handler: @escaping ([PhotoItem]) -> Void) {
        var photoItems = [PhotoItem]()
        
        let ref = Database.database().reference()
        ref.child("photos").observeSingleEvent(of: .value, with: { snapshot in
            
            guard let photos = snapshot.value as? NSDictionary else {
                handler(photoItems)
                return
            }
            
            for photo in photos {
                let photoValue = photo.value as! NSDictionary
                
                let author = photoValue["author"] as? String ?? ""
                let description = photoValue["description"] as? String ?? ""
                let addedDateString = photoValue["addedDate"] as? String ?? Date().toString
                let imageURL = photoValue["imageURL"] as? String ?? ""
                let likesCount = photoValue["likesCount"] as? Int ?? 0
                let liked = photoValue["liked"] as! Bool
                
                var comments = [PhotoItem.Comment]()
                
                if let commentsValueArray = photoValue["comments"] as? NSDictionary {
                    for comment in commentsValueArray {
                        if let comment = comment.value as? NSDictionary {
                            comments.append(PhotoItem.Comment(author: comment["author"] as! String,
                                                              text: comment["text"] as! String))
                        }
                    }
                }
                
                let photoItem = PhotoItem(id: photo.key as! String,
                                          image: nil,
                                          imageURL: imageURL,
                                          author: author,
                                          description: description,
                                          addingDate: Date.fromString(addedDateString),
                                          likesCount: likesCount,
                                          liked: liked,
                                          comments: comments)
                
                
                photoItems.append(photoItem)
            }
            photoItems.sort{ item1, item2 in
                item1.addingDate > item2.addingDate
            }
            handler(photoItems)
        }) { error in
            print(error.localizedDescription)
        }
    }
    
    static func getImageAsync(imageName: String, completion: @escaping (UIImage?) -> Void) {
        if let loadedImage = loadedImagesCash[imageName] {
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
                loadedImagesCash[imageName] = result
                DispatchQueue.main.async {
                    completion(result)
                }
            }
        }
    }

    static func updateLikesInfo(photoItem: PhotoItem) {
        let ref = Database.database().reference()
        let childUpdates = ["/photos/\(photoItem.id)/liked": photoItem.liked,
                            "/photos/\(photoItem.id)/likesCount": photoItem.likesCount] as [String : Any]
        ref.updateChildValues(childUpdates)
    }
    
    static func addComment(photoItem: PhotoItem, comment: PhotoItem.Comment) {
        let ref = Database.database().reference()
        guard let key = ref.child("/photos/\(photoItem.id)/comments").childByAutoId().key else {
            return
        }
        let post = ["author": comment.author,
                    "text": comment.text]
        let childUpdates = ["/photos/\(photoItem.id)/comments/\(key)": post]
        ref.updateChildValues(childUpdates)
    }
    
    static func postItem(image: UIImage, description: String) {
        
        guard let data = image.jpegData(compressionQuality: 1),
                !description.isEmpty else {
            return
        }

        let imageURL = UUID().uuidString + ".jpg"
        
        let photoRef = Storage.storage().reference().child(imageURL)

        let uploadTask = photoRef.putData(data, metadata: nil) { (metadata, error) in
            
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            let ref = Database.database().reference()
            guard let key = ref.child("/photos").childByAutoId().key else {
                print("Upload error")
                return
            }
            let post = ["author": FireBaseController.currentUserName,
                        "description": description,
                        "addedDate": Date().toString,
                        "imageURL": imageURL,
                        "liked": false,
                        "likesCount": 0] as [String : Any]
            let childUpdates = ["/photos/\(key)": post]
            ref.updateChildValues(childUpdates)
            
        }            
        
    }
}
