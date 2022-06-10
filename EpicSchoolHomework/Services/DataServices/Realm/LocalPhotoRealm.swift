//
//  LocalPhotoRealm.swift
//  EpicSchoolHomework
//
//  Created by Vladimir Tezin on 05.06.2022.
//

import UIKit
import RealmSwift
import MapKit

final class LocalPhotoRealm: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var imageData: Data = Data()
    @objc dynamic var title: String?
    @objc dynamic var question: String?
    @objc dynamic var answer: String?
    @objc dynamic var answerDescription: String?
    @objc dynamic var addingDate: Date = Date()
    
    @objc dynamic var latitude: Double = 0
    @objc dynamic var longitude: Double = 0
    @objc dynamic var mapType: String = "standart"
    @objc dynamic var mapSpanDelta: Double = 0.1
    
    override static func primaryKey() -> String? {
      return "id"
    }
}

//Computed properties
extension LocalPhotoRealm {
    var image: UIImage {
        return UIImage(data: imageData) ?? UIImage()
    }
    var mkMapType: MKMapType {
        return mapType == "standart" ? .standard : .satellite
    }
    var mapSpan: MKCoordinateSpan {
        return MKCoordinateSpan(latitudeDelta: mapSpanDelta, longitudeDelta: mapSpanDelta)
    }
}

// MARK: -  Functions
extension LocalPhotoRealm {
    
    static let realm = try! Realm(configuration: RealmService.config)
    
    static func fetchPhotos() -> [LocalPhoto] {
        var localPhotos = [LocalPhoto]()
        
        let realmPhotos = realm.objects(LocalPhotoRealm.self)
        
        for realmPhoto in realmPhotos {
            let localPhoto = LocalPhoto(id: realmPhoto.id,
                                           image: realmPhoto.image,
                                           addingDate: realmPhoto.addingDate,
                                           description: realmPhoto.title,
                                           question: realmPhoto.question,
                                           answer: realmPhoto.answer,
                                           answerDescription: realmPhoto.answerDescription,
                                           latitude: realmPhoto.latitude,
                                           longitude: realmPhoto.longitude,
                                           mapType: realmPhoto.mkMapType,
                                           mapSpan: realmPhoto.mapSpan)
            
            
            localPhotos.append(localPhoto)
        }
        return localPhotos
    }
    
    static func savePhotoToRealm(photo: LocalPhoto) {
        try! realm.write {
            var realmPhoto = LocalPhotoRealm()
            
            if let foundedRealmPhoto = findPhoto(photo: photo) {
                realmPhoto = foundedRealmPhoto
            } else {
                realmPhoto.id = photo.id
            }
            
            realmPhoto.imageData = (photo.image.jpegData(compressionQuality: 0.5))!
            realmPhoto.title = photo.description
            realmPhoto.addingDate = photo.addingDate
            realmPhoto.latitude = photo.latitude
            realmPhoto.longitude = photo.longitude
            realmPhoto.mapType = photo.mapType.rawValue.description
            realmPhoto.mapSpanDelta = photo.mapSpan.latitudeDelta
            
            realm.add(realmPhoto, update: .modified)
        }
    }
    
    static func deletePhoto(photo: LocalPhoto) {
        if let photoRealm = findPhoto(photo: photo) {
            try! realm.write {
                realm.delete(photoRealm)
            }
        }
    }
    
    static private func findPhoto(photo: LocalPhoto) -> LocalPhotoRealm? {
        return realm.objects(LocalPhotoRealm.self).where{
            $0.id == photo.id
        }.first
    }
}
