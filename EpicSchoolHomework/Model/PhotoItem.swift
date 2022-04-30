//
//  PhotoItem.swift
//  EpicSchoolHomework
//
//  Created by Vladimir Tezin on 23.03.2022.
//

import UIKit

// MARK: -  PhotoItem
struct PhotoItem {
    let id: String
    var image: UIImage?
    let imageURL: String
    let author: String
    let description: String
    let addingDate: Date
    var likesCount: Int = 0
    var liked: Bool = false {
        didSet{
            if liked {
                likesCount += 1
            } else {
                likesCount -= 1
            }
            FireBaseDataProvider.updateLikesInfo(photoItem: self)
        }
    }
    
    var comments = [Comment]()
    
    struct Comment {
        let id = UUID()
        let author: String
        var text: String
    }    
}

// MARK: -  computed props

extension PhotoItem {
    var likesFormattedString: String {
        let formatString : String = NSLocalizedString("likes count",
                                                              comment: "Likes count string format to be found in Localized.stringsdict")
        let resultString : String = String.localizedStringWithFormat(formatString, likesCount)
        return resultString;
    }
}

// MARK: -  Functions
extension PhotoItem {
    mutating func likedToggle() {
        liked.toggle()
    }
}

protocol canUpdatePhotoItemInArray {
    func updatePhotoItemInArray(photoItem: PhotoItem, index: Int)
}
