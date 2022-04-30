//
//  Date.swift
//  EpicSchoolHomework
//
//  Created by Vladimir Tezin on 29.04.2022.
//

import Foundation

extension Date {
    
    static var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy/MM/dd/hh/mm/ss"
        return dateFormatter
    }
    
    static func fromString(_ string: String) -> Date {
        return dateFormatter.date(from: string) ?? Date()
    }
    
    var toString: String {
        return Date.dateFormatter.string(from: self)
    }
}
