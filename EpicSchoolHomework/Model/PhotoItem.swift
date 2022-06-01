//
//  PhotoItem.swift
//  EpicSchoolHomework
//
//  Created by Vladimir Tezin on 23.03.2022.
//

import UIKit
import MapKit

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
    var visits = [Visit]()
    
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
    
    struct Visit {
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
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var isVisitedByCurrentUser: Bool {
        isVisitedByUser(userName: FireBaseService.currentUserName)
    }
    
    var isLikedByCurrentUser: Bool {
        isLikedByUser(userName: FireBaseService.currentUserName)
    }
}

// MARK: -  Functions
extension PhotoItem {
    mutating func setVisitedByCurrentUser(_ visited: Bool) {
        if !visited {
            visits.removeAll {$0.user == FireBaseService.currentUserName}
        } else {
            let visit = Visit(user: FireBaseService.currentUserName, date: Date())
            visits.append(visit)
        }
        
        guard FireBaseService.isConnected else {return}
        FireBaseService.updateVisitsInfo(photoItem: self)
    }
    
    mutating func setLikedByCurrentUser(_ liked: Bool) {
        if !liked {
            likes.removeAll {$0.user == FireBaseService.currentUserName}
            NotificationService.shared.deleteNotificationForPhotoItem(self)
        } else {
            let like = Like(user: FireBaseService.currentUserName, date: Date())
            likes.append(like)
            NotificationService.shared.addNotificationForPhotoItem(self)
        }
        
        guard FireBaseService.isConnected else {return}
        FireBaseService.updateLikesInfo(photoItem: self)
    }
    
    func isLikedByUser(userName: String) -> Bool {
        likes.contains {$0.user == userName}
    }
    
    func isVisitedByUser(userName: String) -> Bool {
        visits.contains {$0.user == userName}
    }
}

protocol canUpdatePhotoItemInArray {
    func updatePhotoItemInArray(photoItem: PhotoItem, index: Int)
}
