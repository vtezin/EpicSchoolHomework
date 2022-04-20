//
//  NetworkController.swift
//  EpicSchoolHomework
//
//  Created by Vladimir Tezin on 29.03.2022.
//

import Foundation
import UIKit

class NetworkController {
    
    static func fetchPhotoItems(numberOfItems: Int,
                          handler: @escaping ([PhotoItem]) -> Void) {
        let session = URLSession.shared
        let url = URL(string: "https://picsum.photos/v2/list?page=2&limit=\(numberOfItems)")!
        
        let task = session.dataTask(with: url) { data, response, error in
            
            if error != nil || data == nil {
                print("Client error!")
                return
            }
            
            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                print("Server error!")
                return
            }
            
            guard let mime = response.mimeType, mime == "application/json" else {
                print("Wrong MIME type!")
                return
            }
            
            if let data = data,
               let photoItems = PhotoItem.decodeDataToPhotoItems(data: data) {
                handler(photoItems)
            } else {
                print("No data")
            }
        }
        
        task.resume()
    }
    
}
