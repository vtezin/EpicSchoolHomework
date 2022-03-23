//
//  PhotoItem.swift
//  EpicSchoolHomework
//
//  Created by Vladimir Tezin on 23.03.2022.
//

import UIKit

struct photoItem {
    let image: UIImage
    let autor: String
    let description: String
    var likesCount: Int
    var liked: Bool
}

extension photoItem {
    static var testData: [photoItem] {
        let testItems = (1...10).map{
            photoItem(image: UIImage(named: String($0))!,
                      autor: "autor of photo \($0)",
                      description: "bird \($0)",
                      likesCount: (1...100).randomElement()!,
                      liked: Bool.random())
        }
        
        return testItems
    }
}
