//
//  LocalPhotosViewController.swift
//  EpicSchoolHomework
//
//  Created by Vladimir Tezin on 04.06.2022.
//

import UIKit

protocol LocalPhotoCollectionViewer {
    func photoAdded(localPhoto: LocalPhoto)
    func photoChanged(localPhoto: LocalPhoto, index: Int)
    func photoDeleted(index: Int)
}

final class LocalPhotosViewController: UIViewController, LocalPhotoCollectionViewer {
    @IBOutlet weak var photosCollectionView: UICollectionView!
    
    private lazy var dataSource = makeDataSource()
    private var photos = [LocalPhoto]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        fetchPhotos()
        applySnapshot(animatingDifferences: false)
        title = "Черновики"
    }
}

// MARK: -  collection actions
extension LocalPhotosViewController{
    func photoAdded(localPhoto: LocalPhoto) {
        photos.append(localPhoto)
        applySnapshot()
    }
    
    func photoChanged(localPhoto: LocalPhoto, index: Int) {
        if 0...photos.count - 1 ~= index {
            photos[index] = localPhoto
            applySnapshot()
        }
    }
    
    func photoDeleted(index: Int) {
        photos.remove(at: index)
        applySnapshot()
    }
}

// MARK: -  DiffableDataSource
extension LocalPhotosViewController {
    private func setupCollectionView() {
        photosCollectionView.delegate = self
        
        let nib = UINib(nibName: LocalPhotoCollectionViewCell.reuseIdentifier, bundle: nil)
        photosCollectionView.register(nib, forCellWithReuseIdentifier: LocalPhotoCollectionViewCell.reuseIdentifier)
    }
    
    enum Section {
        case main
    }
    
    fileprivate typealias DataSource = UICollectionViewDiffableDataSource<Section, LocalPhoto>
    
    private func makeDataSource() -> DataSource {
        let dataSource = DataSource(collectionView: photosCollectionView, cellProvider: { (collectionView, indexPath, localPhoto) ->
            UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LocalPhotoCollectionViewCell.reuseIdentifier, for: indexPath) as! LocalPhotoCollectionViewCell
            cell.localPhoto = localPhoto
            cell.configure()
            return cell
        })
        return dataSource
    }
    
    fileprivate typealias Snapshot = NSDiffableDataSourceSnapshot<Section, LocalPhoto>

    private func applySnapshot(animatingDifferences: Bool = true) {
      var snapshot = Snapshot()
      snapshot.appendSections([.main])
      snapshot.appendItems(photos)
      dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
}

// MARK: -  UICollectionViewDelegate
extension LocalPhotosViewController {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let localPhoto = dataSource.itemIdentifier(for: indexPath) else {
          return
        }
        let vc = EditLocalPhotoViewController(photoItem: localPhoto,
                                              indexPhotoItemInArray: indexPath.row,
                                              delegate: self)
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: -  UICollectionViewDelegateFlowLayout
extension LocalPhotosViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let widthPerItem = photosCollectionView.frame.width / 3 - 2
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(
          top: 0,
          left: 1,
          bottom: 0,
          right: 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
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
        fetchPhotos()
    }
}


