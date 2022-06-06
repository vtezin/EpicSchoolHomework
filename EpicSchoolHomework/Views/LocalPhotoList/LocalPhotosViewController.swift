//
//  LocalPhotosViewController.swift
//  EpicSchoolHomework
//
//  Created by Vladimir Tezin on 04.06.2022.
//

import UIKit

final class LocalPhotosViewController: UIViewController, canUpdatePhotoItemInArray {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

// MARK: -  @IBActions
extension LocalPhotosViewController{
    @IBAction func takePhotoFromCamera(_ sender: Any) {
        addNewPhoto(fromCamera: true)
    }
    @IBAction func takePhotoFromGallery(_ sender: Any) {
        addNewPhoto(fromCamera: false)
    }
}

// MARK: -  Functions
extension LocalPhotosViewController {
    private func addNewPhoto(fromCamera: Bool) {
        let vc = EditLocalPhotoViewController(photoItem: nil, indexPhotoItemInArray: nil, delegate: self)
        vc.takeNewPhotoFromCamera = fromCamera
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func updatePhotoItemInArray(photoItem: PhotoItem, index: Int) {
        
    }
}


