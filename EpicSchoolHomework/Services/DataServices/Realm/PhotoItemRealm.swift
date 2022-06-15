//
//  PhotoItemRealm.swift
//  EpicSchoolHomework
//
//  Created by Vladimir Tezin on 06.06.2022.
//

import UIKit
import RealmSwift

final class PhotoItemRealm: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var imageData: Data = Data()
    @objc dynamic var imageURL: String = ""
    @objc dynamic var author: String = ""
    @objc dynamic var photoDescription: String?
    @objc dynamic var question: String?
    @objc dynamic var answer: String?
    @objc dynamic var answerDescription: String?
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

final class PhotoItemRealmVisit: Object {
    @objc dynamic var item: PhotoItemRealm!
    @objc dynamic var user: String = ""
    @objc dynamic var date: Date = Date()
    @objc dynamic var id = UUID().uuidString
    
    override static func primaryKey() -> String? {
      return "id"
    }
}

final class PhotoItemRealmAnswer: Object {
    @objc dynamic var item: PhotoItemRealm!
    @objc dynamic var user: String = ""
    @objc dynamic var date: Date = Date()
    @objc dynamic var id = UUID().uuidString
    
    override static func primaryKey() -> String? {
      return "id"
    }
}

// MARK: -  Fetching
extension PhotoItemRealm {
    static let realm = try! Realm(configuration: RealmService.config)

    static func findItem(photoItem: PhotoItem) -> PhotoItemRealm? {
        return realm.objects(PhotoItemRealm.self).where{
            $0.id == photoItem.id
        }.first
    }
    
    static func fetchPhotoItems() -> [PhotoItem] {
        var photoItems = [PhotoItem]()
        
        let items = realm.objects(PhotoItemRealm.self).sorted(byKeyPath: "addingDate", ascending: false)
        
        for item in items {
            var photoItem = PhotoItem(id: item.id,
                                      image: UIImage(data: item.imageData),
                                      imageURL: item.imageURL,
                                      author: item.author,
                                      description: item.photoDescription,
                                      question: item.question,
                                      answer: item.answer,
                                      answerDescription: item.answerDescription,
                                      addingDate: item.addingDate,
                                      latitude: item.latitude,
                                      longitude: item.longitude)
            let comments = realm.objects(PhotoItemRealmComment.self).sorted(byKeyPath: "date", ascending: true).where{
                $0.item == item
            }
            
            for comment in comments {
                photoItem.comments.append(PhotoItem.Comment(
                    id: comment.id,
                    author: comment.author,
                    text: comment.text,
                    date: comment.date))
            }
            
            let likes = realm.objects(PhotoItemRealmLike.self).sorted(byKeyPath: "date", ascending: true).where{
                $0.item == item
            }
            
            for like in likes {
                photoItem.likes.append(PhotoItem.Like(user: like.user,
                                                      date: like.date))
            }
            
            let visits = realm.objects(PhotoItemRealmVisit.self).sorted(byKeyPath: "date", ascending: true).where{
                $0.item == item
            }
            
            for visit in visits {
                photoItem.visits.append(PhotoItem.Visit(user: visit.user,
                                                      date: visit.date))
            }
            
            let answers = realm.objects(PhotoItemRealmAnswer.self).sorted(byKeyPath: "date", ascending: true).where{
                $0.item == item
            }
            
            for answer in answers {
                photoItem.answers.append(PhotoItem.Answer(user: answer.user,
                                                      date: answer.date))
            }
            
            photoItems.append(photoItem)
            
        }
        return photoItems
    }
    
    static func fetchImageForItem(itemID: String) -> UIImage? {
        let foundedItem = realm.objects(PhotoItemRealm.self).where{
            $0.id == itemID
        }.first
        
        if let foundedItem = foundedItem {
            return UIImage(data: foundedItem.imageData)
        }
        return nil
    }
}

// MARK: -  Saving
extension PhotoItemRealm {
    static func saveItem(photoItem: PhotoItem) {
        try! realm.write {
            let newItem = PhotoItemRealm()
            
            newItem.id = photoItem.id
            newItem.imageData = (photoItem.image?.jpegData(compressionQuality: 0.5))!
            newItem.imageURL = photoItem.imageURL
            newItem.author = photoItem.author
            newItem.photoDescription = photoItem.description ?? ""
            newItem.question = photoItem.question
            newItem.answer = photoItem.answer
            newItem.answerDescription = photoItem.answerDescription
            newItem.addingDate = photoItem.addingDate
            newItem.latitude = photoItem.latitude
            newItem.longitude = photoItem.longitude
            
            realm.add(newItem, update: .modified)
            
            //clear comments
            let comments = realm.objects(PhotoItemRealmComment.self).where{
                $0.item == newItem
            }
            for comment in comments{
                realm.delete(comment)
            }
            
            //clear likes
            let likes = realm.objects(PhotoItemRealmLike.self).where{
                $0.item == newItem
            }
            for like in likes{
                realm.delete(like)
            }
            
            //clear visits
            let visits = realm.objects(PhotoItemRealmLike.self).where{
                $0.item == newItem
            }
            for visit in visits{
                realm.delete(visit)
            }
        
            //clear answers
            let answers = realm.objects(PhotoItemRealmAnswer.self).where{
                $0.item == newItem
            }
            for answer in answers{
                realm.delete(answer)
            }
        }
        
        for comment in photoItem.comments{
            saveComment(photoItem: photoItem, comment: comment)
        }
        
        for like in photoItem.likes{
            saveLike(photoItem: photoItem, like: like)
        }
 
        for visit in photoItem.visits{
            saveVisit(photoItem: photoItem, visit: visit)
        }
        
        for answer in photoItem.answers {
            saveAnswer(photoItem: photoItem, answer: answer)
        }
    }
    
    static func saveComment(photoItem: PhotoItem, comment: PhotoItem.Comment) {
        let items = realm.objects(PhotoItemRealm.self).where{
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
        let items = realm.objects(PhotoItemRealm.self).where{
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
    
    static func saveVisit(photoItem: PhotoItem, visit: PhotoItem.Visit) {
        let items = realm.objects(PhotoItemRealm.self).where{
            $0.id == photoItem.id
        }
        
        guard let item = items.first else {return}
        
        try! realm.write {
            let newVisit = PhotoItemRealmVisit()
            newVisit.user = visit.user
            newVisit.date = visit.date
            newVisit.item = item
            realm.add(newVisit, update: .modified)
        }
    }
    
    static func saveAnswer(photoItem: PhotoItem, answer: PhotoItem.Answer) {
        let items = realm.objects(PhotoItemRealm.self).where{
            $0.id == photoItem.id
        }
        
        guard let item = items.first else {return}
        
        try! realm.write {
            let newAnswer = PhotoItemRealmAnswer()
            newAnswer.user = answer.user
            newAnswer.date = answer.date
            newAnswer.item = item
            realm.add(newAnswer, update: .modified)
        }
    }
}

// MARK: -  Delete
extension PhotoItemRealm{
    
    static func deleteAllItems() {
        let items = realm.objects(PhotoItemRealm.self)
        for item in items {
            deleteItem(item)
        }
    }
    
    static func deleteItem(_ item: PhotoItemRealm) {
        deleteItemLikes(item: item)
        deleteItemComments(item: item)
        deleteItemVisits(item: item)
        deleteItemAnswers(item: item)
        
        try! realm.write {
            realm.delete(item)
        }
    }
    
    static private func deleteItemAnswers(item: PhotoItemRealm) {
        try! realm.write {
            let records = realm.objects(PhotoItemRealmAnswer.self).where{
                $0.item == item
            }
            for record in records{
                realm.delete(record)
            }
        }
    }
    
    static private func deleteItemLikes(item: PhotoItemRealm) {
        try! realm.write {
            let records = realm.objects(PhotoItemRealmLike.self).where{
                $0.item == item
            }
            for record in records{
                realm.delete(record)
            }
        }
    }
    
    static private func deleteItemComments(item: PhotoItemRealm) {
        try! realm.write {
            let records = realm.objects(PhotoItemRealmComment.self).where{
                $0.item == item
            }
            for record in records{
                realm.delete(record)
            }
        }
    }
 
    static private func deleteItemVisits(item: PhotoItemRealm) {
        try! realm.write {
            let records = realm.objects(PhotoItemRealmVisit.self).where{
                $0.item == item
            }
            for record in records{
                realm.delete(record)
            }
        }
    }
    
}
