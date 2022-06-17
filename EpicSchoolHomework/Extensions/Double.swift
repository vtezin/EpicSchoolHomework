//
//  Double.swift
//  EpicSchoolHomework
//
//  Created by Vladimir Tezin on 17.06.2022.
//

import Foundation

extension Double {
    var string2s: String {
        return String(format: "%.2f", self)
    }
    
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }    
}
