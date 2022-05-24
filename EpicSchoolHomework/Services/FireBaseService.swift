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

class FireBaseService {
    static var loadedImagesCash = [String: UIImage]()
    static var currentUserName: String {
        if let curUser = Auth.auth().currentUser {
            return curUser.email ?? "??"
        } else {
           return "??"
        }
    }
    static var isConnected = false {
        didSet{
            print("isConnected = \(isConnected)")
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
                let latitude = photoValue["latitude"] as? Double ?? 0
                let longitude = photoValue["longitude"] as? Double ?? 0
                
                var comments = [PhotoItem.Comment]()
                
                if let commentsValueArray = photoValue["comments"] as? NSDictionary {
                    for comment in commentsValueArray {
                        let commentID = comment.key as! String
                        
                        if let commentValue = comment.value as? NSDictionary {
                            let commentAutor = commentValue["author"] as? String ?? "??"
                            let commentDateString = commentValue["date"] as? String ?? Date().toString
                            let commentText = commentValue["text"] as? String ?? "??"
                            
                            let photoItemComment = PhotoItem.Comment(id: commentID,
                                                                     author: commentAutor,
                                                                     text: commentText,
                                                                     date: Date.fromString(commentDateString))
                            
                            comments.append(photoItemComment)
                        }
                    }
                }
                
                comments.sort{$0.date < $1.date}
                
                var likes = [PhotoItem.Like]()
                
                if let likesValueArray = photoValue["likes"] as? NSDictionary {
                    for like in likesValueArray {
                        
                        if let likeValue = like.value as? NSDictionary {
                            let likeUser = likeValue["user"] as? String ?? "??"
                            let likeDateString = likeValue["date"] as? String ?? Date().toString
                            
                            let photoItemLike = PhotoItem.Like(user: likeUser,
                                                               date: Date.fromString(likeDateString))
                            
                            likes.append(photoItemLike)
                        }
                    }
                }
                
                likes.sort{$0.date < $1.date}
                
                let photoItem = PhotoItem(id: photo.key as! String,
                                          image: nil,
                                          imageURL: imageURL,
                                          author: author,
                                          description: description,
                                          addingDate: Date.fromString(addedDateString),
                                          latitude: latitude,
                                          longitude: longitude,
                                          comments: comments,
                                          likes: likes)
                
                photoItems.append(photoItem)
            }
            photoItems.sort{$0.addingDate > $1.addingDate}
            handler(photoItems)
        }) { error in
            print(error.localizedDescription)
            handler(RealmService.fetchItems())
            return
        }
    }

    static func getImage(imageName: String, completion: @escaping (UIImage?) -> Void) {
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
                ImagesService.loadedImagesCash[imageName] = result
                DispatchQueue.main.async {
                    completion(result)
                }
            }
        }
    }
    
    static func updateLikesInfo(photoItem: PhotoItem) {
        let ref = Database.database().reference()
        let key = currentUserName.filter{$0 != "@" && $0 != "."
        }
        
        if photoItem.isLikedByUser(userName: currentUserName) {
            let post = ["user": currentUserName,
                        "date": Date().toString]
            let childUpdates = ["/photos/\(photoItem.id)/likes/\(key)": post]
            ref.updateChildValues(childUpdates)
        } else {
            let childUpdates = ["/photos/\(photoItem.id)/likes/\(key)": nil] as [String : Any?]
            ref.updateChildValues(childUpdates as [AnyHashable : Any])
        }
    }
    
    static func addComment(photoItem: PhotoItem, comment: PhotoItem.Comment) {
        let ref = Database.database().reference()
        let key = comment.id
        let post = ["author": comment.author,
                    "text": comment.text,
                    "date": Date().toString]
        let childUpdates = ["/photos/\(photoItem.id)/comments/\(key)": post]
        ref.updateChildValues(childUpdates)
    }
    
    static func postItem(image: UIImage,
                         description: String,
                         latitude: Double?,
                         longitude: Double?) {
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
            let post = ["author": FireBaseService.currentUserName,
                        "description": description,
                        "addedDate": Date().toString,
                        "imageURL": imageURL,
                        "liked": false,
                        "latitude": latitude ?? 0,
                        "longitude": longitude ?? 0,
                        "likesCount": 0] as [String : Any]
            let childUpdates = ["/photos/\(key)": post]
            ref.updateChildValues(childUpdates)
        }            
    }
}
