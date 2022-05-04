//
//  DataProvider.swift
//  EpicSchoolHomework
//
//  Created by Vladimir Tezin on 18.04.2022.
//

import Foundation

protocol DataProvider {
    func fetchPhotoItems() -> [PhotoItem]
}
