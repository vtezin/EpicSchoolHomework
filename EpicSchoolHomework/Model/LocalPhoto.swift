//
//  PhotoLocal.swift
//  EpicSchoolHomework
//
//  Created by Vladimir Tezin on 03.06.2022.
//

import Foundation
import UIKit
import MapKit
import RealmSwift

struct LocalPhoto {
//    let id = UUID().uuidString
//    let image: UIImage? = UIImage()
//    let addingDate = Date()
//    //geo data
//    let latitude: Double = 0
//    let longitude: Double = 0
//    var description: String?
//    var mapType: MKMapType = .standard
//    var mapSpan: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    
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

// MARK: -  computed properties
extension LocalPhoto {
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
