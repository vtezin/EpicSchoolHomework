//
//  PhotoItem.swift
//  EpicSchoolHomework
//
//  Created by Vladimir Tezin on 23.03.2022.
//

import UIKit

// MARK: -  PhotoItem
struct PhotoItem {
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
        }
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
            PhotoItem(image: UIImage(named: String($0))!,
                      imageURL: "",
                      author: "автор фото \($0)",
                      description: "птичка \($0)",
                      likesCount: (1...100).randomElement()!,
                      liked: Bool.random())
        }
        
        return testItems
    }
}

// MARK: -  fetching data from web
extension PhotoItem {
    
    private struct PhotoItemFromWeb: Codable {
        let url: String
        let download_url: String
        let author: String
    }
    
    static func fetchDataFromWeb(handler: @escaping (Data) -> Void) {
        NetworkController.fetchData(handler: handler)
    }
    
    static func decodeDataToPhotoItems(data: Data) -> [PhotoItem]? {
        do {
            let photoItemsFromWeb = try JSONDecoder().decode([PhotoItem.PhotoItemFromWeb].self, from: data)
            
            //convert PhotoItemFromWeb to PhotoItem
            var photoItems = [PhotoItem]()
            
            for photoItemFromWeb in photoItemsFromWeb {
                
                let photoItem = PhotoItem(image: nil,
                                          imageURL: photoItemFromWeb.download_url,
                                          author: photoItemFromWeb.author,
                                          description: "the best photo of \(photoItemFromWeb.author)",
                                          likesCount: Int.random(in: 1...100),
                                          liked: Bool.random())
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
