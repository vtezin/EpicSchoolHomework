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
    let description: String? //TODO: rename to title everywhere
    let question: String?
    let answer: String?
    let answerDescription: String?
    let addingDate: Date
    //geo data
    let latitude: Double
    let longitude: Double
    var mapType: MKMapType = .standard
    var mapSpan: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    
    var comments = [Comment]()
    var likes = [Like]()
    var visits = [Visit]()
    var answers = [Answer]()
    
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
    
    struct Answer {
        let user: String
        let date: Date
    }
}

// MARK: -  Hashable
extension PhotoItem: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: PhotoItem, rhs: PhotoItem) -> Bool {
        lhs.id == rhs.id
        && lhs.image == rhs.image
    }
}

// MARK: -  Computed props
extension PhotoItem {
    var wrappedDescription: String {
        description ?? ""
    }
    
    var likesFormattedString: String {
        let formatString : String = NSLocalizedString("likes count",
                                                              comment: "Likes count string format to be found in Localized.stringsdict")
        let resultString : String = String.localizedStringWithFormat(formatString, likes.count)
        return resultString;
    }
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var hasQuestion: Bool {
        if let question = question {
            return !question.isEmpty
        } else {
            return false
        }
    }
    
    var isVisitedByCurrentUser: Bool {
        isVisitedByUser(userName: appState.currentUserName)
    }
    
    var isLikedByCurrentUser: Bool {
        isLikedByUser(userName: appState.currentUserName)
    }
    
    var isAnsweredByCurrentUser: Bool {
        isAnsweredByUser(userName: appState.currentUserName)
    }
    
    var likedImage: UIImage {
        UIImage(systemName: isLikedByCurrentUser ?
                "hand.thumbsup.fill" :
                    "hand.thumbsup") ?? UIImage()
    }
    
    var visitedImage: UIImage {
        UIImage(systemName: isVisitedByCurrentUser ?
                "eye.fill" :
                    "eye") ?? UIImage()
    }
    
    var answeredImage: UIImage {
        UIImage(systemName: isAnsweredByCurrentUser ?
                "questionmark.circle.fill" :
                    "questionmark.circle") ?? UIImage()
    }
}

// MARK: -  Functions
extension PhotoItem {
    mutating func setVisitedByCurrentUser(_ visited: Bool) {
        if !visited {
            visits.removeAll {$0.user == appState.currentUserName}
        } else {
            let visit = Visit(user: appState.currentUserName, date: Date())
            visits.append(visit)
        }
        
        guard FireBaseService.isConnected else {return}
        FireBaseService.updateVisitsInfo(photoItem: self)
    }
    
    mutating func setLikedByCurrentUser(_ liked: Bool) {
        if !liked {
            likes.removeAll {$0.user == appState.currentUserName}
            NotificationService.shared.deleteNotificationForPhotoItem(self)
        } else {
            let like = Like(user: appState.currentUserName, date: Date())
            likes.append(like)
            let item = self
            DispatchQueue.global(qos: .background).async {
                NotificationService.shared.addNotificationForPhotoItem(item)
            }
        }
        
        guard FireBaseService.isConnected else {return}
        FireBaseService.updateLikesInfo(photoItem: self)
    }
    
    mutating func setAnsweredByCurrentUser() {
        if !answers.contains(where: {$0.user == appState.currentUserName}) {
            let answer = Answer(user: appState.currentUserName, date: Date())
            answers.append(answer)
        }
        guard FireBaseService.isConnected else {return}
        FireBaseService.updateAnswersInfo(photoItem: self)
    }
    
    mutating func setImage(image: UIImage) {
        self.image = image
    }
    
    func isLikedByUser(userName: String) -> Bool {
        likes.contains {$0.user == userName}
    }
    
    func isVisitedByUser(userName: String) -> Bool {
        visits.contains {$0.user == userName}
    }
    
    func isAnsweredByUser(userName: String) -> Bool {
        answers.contains {$0.user == userName}
    }
    
    func answerIsCorrect(answer: String) -> Bool {
        answer.capitalized == self.answer?.capitalized
    }
}
