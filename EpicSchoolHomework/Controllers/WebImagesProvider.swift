//
//  ImagesProvider.swift
//  EpicSchoolHomework
//
//  Created by Vladimir Tezin on 18.04.2022.
//

import Foundation
import UIKit

final class WebImagesProvider {
    
    static var loadedImages = [String: UIImage]()
    
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
                loadedImages[stringUrl] = result
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
    
}
