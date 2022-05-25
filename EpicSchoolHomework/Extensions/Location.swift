//
//  Location.swift
//  EpicSchoolHomework
//
//  Created by Vladimir Tezin on 25.05.2022.
//

import Foundation

func localeDistanceString(distanceMeters: Double) -> String {
    if distanceMeters < 1 {
        return "0"
    } else {
        let formatter = MeasurementFormatter()
        let distanceInMeters = Measurement(value: Double(Int(distanceMeters)), unit: UnitLength.meters)
        formatter.unitStyle = MeasurementFormatter.UnitStyle.short
        formatter.unitOptions = .naturalScale
        
        return formatter.string(from: distanceInMeters)
    }
}
