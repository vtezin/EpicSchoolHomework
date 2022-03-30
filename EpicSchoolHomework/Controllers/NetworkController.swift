//
//  NetworkController.swift
//  EpicSchoolHomework
//
//  Created by Vladimir Tezin on 29.03.2022.
//

import Foundation

class NetworkController {
    
    static func fetchData(handler: @escaping (Data) -> Void) {
        
        let session = URLSession.shared
        let url = URL(string: "https://picsum.photos/v2/list?page=2&limit=10")!
        
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

            if let data = data {
                handler(data)
            } else {
                print("No data")
            }
        }

        task.resume()
        
    }
}
