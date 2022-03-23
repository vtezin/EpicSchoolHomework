//
//  PhotoItem.swift
//  EpicSchoolHomework
//
//  Created by Vladimir Tezin on 23.03.2022.
//

import UIKit

// MARK: -  PhotoItem
struct PhotoItem {
    let image: UIImage
    let autor: String
    let description: String
    var likesCount: Int
    var liked: Bool {
        didSet{
            if liked {
                likesCount += 1
            } else {
                likesCount -= 1
            }
        }
    }
    
    var likesCountDescription: String {
        var likesString: String
        
        if 11...14 ~= likesCount {
            likesString = "Лайков"
        } else {
            switch likesCount % 10{
            case 1:
                likesString = "Лайк"
            case 2...4:
                likesString = "Лайка"
            default:
                likesString = "Лайков"
            }
        }
        
        return "\(likesCount) \(likesString)"
    }
}

// MARK: -  Functions
extension PhotoItem {
    mutating func likedToggle() {
        liked.toggle()
    }
}

// MARK: -  Test data
extension PhotoItem {
    static var testData: [PhotoItem] {
        let testItems = (1...10).map{
            PhotoItem(image: UIImage(named: String($0))!,
                      autor: "автор фото \($0)",
                      description: "птичка \($0)",
                      likesCount: (1...100).randomElement()!,
                      liked: Bool.random())
        }
        
        return testItems
    }
}
