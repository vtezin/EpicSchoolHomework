//
//  UIImage.swift
//  EpicSchoolHomework
//
//  Created by Vladimir Tezin on 15.06.2022.
//

import UIKit

extension UIImage {
    var compressedData: Data? {
        self.jpegData(compressionQuality: 0.1)
    }
    
    var compressedImage: UIImage? {
        if let data = compressedData {
            return UIImage(data: data)
        } else {
            return nil
        }
    }
}
