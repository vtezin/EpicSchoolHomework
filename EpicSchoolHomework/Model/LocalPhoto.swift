//
//  PhotoLocal.swift
//  EpicSchoolHomework
//
//  Created by Vladimir Tezin on 03.06.2022.
//

import Foundation
import UIKit
import MapKit

struct LocalPhoto: PhotoContainer {
    let id: String
    let image: UIImage?
    //geo data
    let latitude: Double
    let longitude: Double
    var description: String?
    var mapType: MKMapType = .standard
    var mapSpan: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
}
