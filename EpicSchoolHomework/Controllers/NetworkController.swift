//
//  NetworkController.swift
//  EpicSchoolHomework
//
//  Created by Vladimir Tezin on 29.03.2022.
//

import Foundation
import UIKit

class NetworkController {
    
    static func fetchData(handler: @escaping (Data) -> Void) {
        let session = URLSession.shared
        let url = URL(string: "https://picsum.photos/v2/list?page=2&limit=5")!
        
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
    
    static func getImage(with stringUrl: String?, completion: @escaping (UIImage?) -> Void) {
        
        if let stringUrl = stringUrl,
           let loadedImage = loadedImages[stringUrl] {
            DispatchQueue.main.async {
                completion(loadedImage)
            }
        }
        
        guard
            let stringUrl = stringUrl,
            let url = URL(string: stringUrl)
        else {
            completion(nil)
            return
        }
        
        // здесь мы заставляем загружать нашу картинку в фоновом потоке,
        // тем самым не блокируем UI
        DispatchQueue.global(qos: .background).async {
            let result: UIImage?
            
            if let imageData = try? Data(contentsOf: url) {
                result = UIImage(data: imageData)
                NetworkController.loadedImages[stringUrl] = result
            } else {
                result = nil
            }
            
            // по окончанию загрузки здесь мы указываем, что хотим передать результат
            // с картинкой в UI-потоке (только в этом потоке мы можем корректно изменять
            // свойства наших View)
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
    
    static var loadedImages = [String: UIImage]()
    
}
