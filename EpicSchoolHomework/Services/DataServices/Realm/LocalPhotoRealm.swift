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
    @objc dynamic var title: String = ""
    @objc dynamic var question: String = ""
    @objc dynamic var answer: String = ""
    @objc dynamic var addingDate: Date = Date()
    
    @objc dynamic var latitude: Double = 0
    @objc dynamic var longitude: Double = 0
    @objc dynamic var mapType: String = "standart"
    @objc dynamic var mapSpanDelta: Double = 0.1
    
    override static func primaryKey() -> String? {
      return "id"
    }
}

// MARK: -  Functions
extension LocalPhotoRealm {
    
    static let realm = try! Realm(configuration: RealmService.config)
    
    static func fetchPhotos() -> [LocalPhoto] {
        var localPhotos = [LocalPhoto]()
        
        let realmPhotos = realm.objects(LocalPhotoRealm.self)
        
        for realmPhoto in realmPhotos {
            let newLocalPhoto = LocalPhoto(id: realmPhoto.id,
                                           image: UIImage(data: realmPhoto.imageData) ?? UIImage(),
                                           addingDate: realmPhoto.addingDate,
                                           latitude: realmPhoto.latitude,
                                           longitude: realmPhoto.longitude,
                                           description: realmPhoto.title,
                                           mapType: realmPhoto.mapType == "standart" ? .standard : .satellite,
                                           mapSpan: MKCoordinateSpan(latitudeDelta: realmPhoto.mapSpanDelta, longitudeDelta: realmPhoto.mapSpanDelta))
            localPhotos.append(newLocalPhoto)
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
    
    static func publishPhotoToFirebase(photo: LocalPhoto) {
        FireBaseService.postItem(image: photo.image,
                                 description: photo.description,
                                 latitude: photo.latitude,
                                 longitude: photo.longitude)
        deletePhoto(photo: photo)
    }
    
    static private func findPhoto(photo: LocalPhoto) -> LocalPhotoRealm? {
        return realm.objects(LocalPhotoRealm.self).where{
            $0.id == photo.id
        }.first
    }
}
