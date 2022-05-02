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
        return Date.dateFormatter.date(from: string) ?? Date()
    }
    
    var toString: String {
        return Date.dateFormatter.string(from: self)
    }
    
    var stringDescription: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.doesRelativeDateFormatting = true
        return formatter.string(from: self)        
    }
}
