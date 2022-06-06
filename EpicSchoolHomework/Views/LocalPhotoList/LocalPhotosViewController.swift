//
//  LocalPhotosViewController.swift
//  EpicSchoolHomework
//
//  Created by Vladimir Tezin on 04.06.2022.
//

import UIKit

final class LocalPhotosViewController: UIViewController, canUpdatePhotoItemInArray {
    @IBOutlet weak var photosCollectionView: UICollectionView!
    
    private var photos = [LocalPhoto]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        fetchPhotos()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchPhotos()
    }
}

// MARK: -  UICollectionViewDataSource,
extension LocalPhotosViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let photo = photos[indexPath.row]
        let cell = photosCollectionView.dequeueReusableCell(withReuseIdentifier: LocalPhotoCollectionViewCell.reuseIdentifier, for: indexPath) as! LocalPhotoCollectionViewCell
        cell.localPhoto = photo
        cell.configureCell()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let widthPerItem = view.frame.width / 4
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    
    private func setupCollectionView() {
        photosCollectionView.dataSource = self
        photosCollectionView.delegate = self
        
        let nib = UINib(nibName: LocalPhotoCollectionViewCell.reuseIdentifier, bundle: nil)
        photosCollectionView.register(nib, forCellWithReuseIdentifier: LocalPhotoCollectionViewCell.reuseIdentifier)
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
    
    private func fetchPhotos() {
        photos = LocalPhotoRealm.fetchPhotos()
        photosCollectionView.reloadData()
    }
    
    func updatePhotoItemInArray(photoItem: PhotoItem, index: Int) {
        
    }
}


