//
//  PhotoContainer.swift
//  EpicSchoolHomework
//
//  Created by Vladimir Tezin on 03.06.2022.
//

import Foundation
import UIKit
import MapKit

protocol PhotoContainer {
    var id: String {get}
    var image: UIImage? {get}
    var addingDate: Date {get}
    //geo data
    var latitude: Double {get}
    var longitude: Double {get}
    var description: String? {get set}
    //map options
    var mapType: MKMapType {get set}
    var mapSpan: MKCoordinateSpan {get set}
}
