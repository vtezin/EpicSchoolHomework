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
    //geo data
    let latitude: Double
    let longitude: Double
    
    var comments = [Comment]()
    var likes = [Like]()
    
    struct Comment {
        let id: String
        let author: String
        var text: String
        let date: Date
    }
    
    struct Like {
        let user: String
        let date: Date
    }
}

// MARK: -  computed props

extension PhotoItem {
    var likesFormattedString: String {
        let formatString : String = NSLocalizedString("likes count",
                                                              comment: "Likes count string format to be found in Localized.stringsdict")
        let resultString : String = String.localizedStringWithFormat(formatString, likes.count)
        return resultString;
    }
}

// MARK: -  Functions
extension PhotoItem {    
    mutating func toggleLikeByUser(userName: String) {
        if isLikedByUser(userName: userName) {
            likes.removeAll {$0.user == userName}
        } else {
            let like = Like(user: userName, date: Date())
            likes.append(like)
        }
    }
    
    func isLikedByUser(userName: String) -> Bool {
        likes.contains {$0.user == userName}
    }
}


protocol canUpdatePhotoItemInArray {
    func updatePhotoItemInArray(photoItem: PhotoItem, index: Int)
}
