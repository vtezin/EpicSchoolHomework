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
    var likesCount: Int
    var liked: Bool {
        didSet{
            if liked {
                likesCount += 1
            } else {
                likesCount -= 1
            }
            FireBaseDataProvider.shared.updateLikesInfo(photoItem: self)
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

// MARK: -  Test data
extension PhotoItem {
    static var testData: [PhotoItem] {
        let testItems = (1...10).map{
            PhotoItem(id: String($0),
                      image: UIImage(named: String($0))!,
                      imageURL: "",
                      author: "автор фото \($0)",
                      description: "птичка \($0)",
                      likesCount: (1...100).randomElement()!,
                      liked: Bool.random())
        }
        
        return testItems
    }
}

// MARK: -  fetching data from Firebase
extension PhotoItem {
    
    static func fetchDataFromFirebase(handler: @escaping ([PhotoItem]) -> Void) {
        FireBaseDataProvider.shared.fetchPhotoItems(handler: handler)
    }
    
}

// MARK: -  fetching data from web
extension PhotoItem {
    
    private struct PhotoItemFromWeb: Codable {
        let url: String
        let download_url: String
        let author: String
    }
    
    static func fetchDataFromWeb(numberOfItems: Int,
                                 handler: @escaping ([PhotoItem]) -> Void) {
        NetworkController.fetchPhotoItems(numberOfItems: numberOfItems, handler: handler)
    }
    
    static func decodeDataToPhotoItems(data: Data) -> [PhotoItem]? {
        do {
            let photoItemsFromWeb = try JSONDecoder().decode([PhotoItem.PhotoItemFromWeb].self, from: data)
            
            //convert PhotoItemFromWeb to PhotoItem
            var photoItems = [PhotoItem]()
            
            for photoItemFromWeb in photoItemsFromWeb {
                
                var photoItem = PhotoItem(id: photoItemFromWeb.download_url,
                                          image: nil,
                                          imageURL: photoItemFromWeb.download_url,
                                          author: photoItemFromWeb.author,
                                          description: "the best photo of \(photoItemFromWeb.author)",
                                          likesCount: Int.random(in: 1...100),
                                          liked: Bool.random())
                photoItem.comments.append(PhotoItem.Comment(author: photoItem.author, text: "This is my best photo!"))
                photoItems.append(photoItem)
                
            }
            return photoItems
        } catch {
            print("Data error: \(error)")
        }
        return nil
    }
    
    
    enum CodingKeys: String, CodingKey {
        case author = "author"
        case description = "url"
    }
    
}

protocol canUpdatePhotoItemInArray {
    func updatePhotoItemInArray(photoItem: PhotoItem, index: Int)
}
