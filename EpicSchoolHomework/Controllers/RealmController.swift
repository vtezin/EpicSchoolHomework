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
    @objc dynamic var likesCount: Int = 0
    @objc dynamic var liked = false
    
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

final class RealmController {
    static let config = Realm.Configuration(schemaVersion: 1)
    
    static func saveItem(photoItem: PhotoItem) {
        //return
        let realm = try! Realm(configuration: config)
        try! realm.write {
            let newItem = PhotoItemRealm()
            
            newItem.id = photoItem.id
            newItem.imageData = (photoItem.image?.jpegData(compressionQuality: 5))!
            newItem.imageURL = photoItem.imageURL
            newItem.author = photoItem.author
            newItem.photoDescription = photoItem.description
            newItem.addingDate = photoItem.addingDate
            newItem.likesCount = photoItem.likesCount
            newItem.liked = photoItem.liked
            
            realm.add(newItem, update: .all)
            
            for comment in photoItem.comments {
                let newComment = PhotoItemRealmComment()
                newComment.id = comment.id
                newComment.author = comment.author
                newComment.text = comment.text
                newComment.item = newItem
                realm.add(newComment, update: .all)
            }
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
                                      likesCount: item.likesCount,
                                      liked: item.liked,
                                      comments: [PhotoItem.Comment]())
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
            photoItems.append(photoItem)
            
        }
        return photoItems
    }
}
