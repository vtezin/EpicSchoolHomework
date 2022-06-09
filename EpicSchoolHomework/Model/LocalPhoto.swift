//
//  PhotoLocal.swift
//  EpicSchoolHomework
//
//  Created by Vladimir Tezin on 03.06.2022.
//

import UIKit
import MapKit
import RealmSwift

struct LocalPhoto {
    let id: String
    let image: UIImage
    let addingDate: Date
    //geo data
    let latitude: Double
    let longitude: Double
    var description: String
    var mapType: MKMapType
    var mapSpan: MKCoordinateSpan
}

// MARK: -  Hashable
extension LocalPhoto: Hashable {
    func hash(into hasher: inout Hasher) {
      hasher.combine(id)
    }
    
    static func == (lhs: LocalPhoto, rhs: LocalPhoto) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: -  computed properties
extension LocalPhoto {
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

// MARK: -  Functions
extension LocalPhoto {
    static func publishPhoto(_ localPhoto: LocalPhoto) {
        guard appState.firebaseIsConnected else {return}
        PhotoItemRealm.saveItem(photoItem: localPhoto.convertToPhotoItem())
        FireBaseService.postItem(image: localPhoto.image,
                                 description: localPhoto.description,
                                 latitude: localPhoto.latitude,
                                 longitude: localPhoto.longitude)
        LocalPhotoRealm.deletePhoto(photo: localPhoto)
    }
    
    func convertToPhotoItem() -> PhotoItem {
        return PhotoItem(id: id,
                         image: image,
                         imageURL: "",
                         author: FireBaseService.currentUserName,
                         description: description,
                         addingDate: addingDate,
                         latitude: latitude,
                         longitude: longitude,
                         mapType: mapType,
                         mapSpan: mapSpan)
    }
}
