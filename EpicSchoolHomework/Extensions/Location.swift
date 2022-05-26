//
//  Location.swift
//  EpicSchoolHomework
//
//  Created by Vladimir Tezin on 25.05.2022.
//

import Foundation

func localeDistanceString(distanceMeters: Double) -> String {    
    //round to meters
    var distance = Int(distanceMeters)
    
    //round to kilimeters
    if distance > 5000 {
        distance = Int(Double(distance/1000).rounded()) * 1000
    }
    
    let formatter = MeasurementFormatter()
    let distanceInMeters = Measurement(value: Double(Int(distance)), unit: UnitLength.meters)
    formatter.unitStyle = MeasurementFormatter.UnitStyle.short
    formatter.unitOptions = .naturalScale
    
    return formatter.string(from: distanceInMeters)
}
