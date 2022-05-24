//
//  RealmController.swift
//  EpicSchoolHomework
//
//  Created by Vladimir Tezin on 30.04.2022.
//

import Foundation
import RealmSwift
import UIKit

final class PhotoItemRealm: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var imageData: Data = Data()
    @objc dynamic var imageURL: String = ""
    @objc dynamic var author: String = ""
    @objc dynamic var photoDescription: String = ""
    @objc dynamic var addingDate: Date = Date()
    @objc dynamic var latitude: Double = 0
    @objc dynamic var longitude: Double = 0
    
    override static func primaryKey() -> String? {
      return "id"
    }
}

final class PhotoItemRealmComment: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var item: PhotoItemRealm!
    @objc dynamic var author: String = ""
    @objc dynamic var text: String = ""
    @objc dynamic var date: Date = Date()
    
    override static func primaryKey() -> String? {
      return "id"
    }
}

final class PhotoItemRealmLike: Object {
    @objc dynamic var item: PhotoItemRealm!
    @objc dynamic var user: String = ""
    @objc dynamic var date: Date = Date()
    @objc dynamic var id = UUID().uuidString
    
    override static func primaryKey() -> String? {
      return "id"
    }
}

final class RealmService {
    static let config = Realm.Configuration(schemaVersion: 5)
    
    static func saveItem(photoItem: PhotoItem) {
        let realm = try! Realm(configuration: config)
        //print("Realm is located at:", realm.configuration.fileURL!)
        
        try! realm.write {
            let newItem = PhotoItemRealm()
            
            newItem.id = photoItem.id
            newItem.imageData = (photoItem.image?.jpegData(compressionQuality: 0.5))!
            newItem.imageURL = photoItem.imageURL
            newItem.author = photoItem.author
            newItem.photoDescription = photoItem.description
            newItem.addingDate = photoItem.addingDate
            newItem.latitude = photoItem.latitude
            newItem.longitude = photoItem.longitude
            
            realm.add(newItem, update: .modified)
            
            //clear likes info
            let likes = realm.objects(PhotoItemRealmLike.self).where{
                $0.item == newItem
            }
            for like in likes{
                realm.delete(like)
            }
        }
        
        for comment in photoItem.comments{
            saveComment(photoItem: photoItem, comment: comment)
        }
        
        
        for like in photoItem.likes{
            saveLike(photoItem: photoItem, like: like)
        }
    }
    
    static func saveComment(photoItem: PhotoItem, comment: PhotoItem.Comment) {
        let realm = try! Realm(configuration: config)
        
        let items = try! Realm(configuration: config).objects(PhotoItemRealm.self).where{
            $0.id == photoItem.id
        }
        
        guard let item = items.first else {return}
        
        try! realm.write {
            let newComment = PhotoItemRealmComment()
            newComment.id = comment.id
            newComment.author = comment.author
            newComment.text = comment.text
            newComment.item = item
            newComment.date = comment.date
            realm.add(newComment, update: .modified)
        }
    }
    
    static func saveLike(photoItem: PhotoItem, like: PhotoItem.Like) {
        let realm = try! Realm(configuration: config)
        
        let items = try! Realm(configuration: config).objects(PhotoItemRealm.self).where{
            $0.id == photoItem.id
        }
        
        guard let item = items.first else {return}
        
        try! realm.write {
            let newLike = PhotoItemRealmLike()
            newLike.user = like.user
            newLike.date = like.date
            newLike.item = item
            realm.add(newLike, update: .modified)
        }
    }
    
    static func fetchItems() -> [PhotoItem] {
        var photoItems = [PhotoItem]()
        
        let items = try! Realm(configuration: config).objects(PhotoItemRealm.self).sorted(byKeyPath: "addingDate", ascending: false)
        
        for item in items {
            var photoItem = PhotoItem(id: item.id,
                                      image: UIImage(data: item.imageData),
                                      imageURL: item.imageURL,
                                      author: item.author,
                                      description: item.photoDescription,
                                      addingDate: item.addingDate,
                                      latitude: item.latitude,
                                      longitude: item.longitude)
            let comments = try! Realm(configuration: config).objects(PhotoItemRealmComment.self).sorted(byKeyPath: "date", ascending: true).where{
                $0.item == item
            }
            
            for comment in comments {
                photoItem.comments.append(PhotoItem.Comment(
                    id: comment.id,
                    author: comment.author,
                    text: comment.text,
                    date: comment.date))
            }
            
            let likes = try! Realm(configuration: config).objects(PhotoItemRealmLike.self).sorted(byKeyPath: "date", ascending: true).where{
                $0.item == item
            }
            
            for like in likes {
                photoItem.likes.append(PhotoItem.Like(user: like.user,
                                                      date: like.date))
            }
            
            photoItems.append(photoItem)
            
        }
        return photoItems
    }
}
