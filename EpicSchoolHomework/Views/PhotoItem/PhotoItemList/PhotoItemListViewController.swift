//
//  PhotoItemListViewController.swift
//  EpicSchoolHomework
//
//  Created by Vladimir Tezin on 08.06.2022.
//

import UIKit
import Combine

final class PhotoItemListViewController: UIViewController {
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var loadingIndicator: UIActivityIndicatorView!
    
    private lazy var dataSource = makeDataSource()
    private var photoItems = [PhotoItem]()
    private var subscriptions = Set<AnyCancellable>()
    
    private let firebaseStatusBarItem = UIBarButtonItem(title: "Оффлайн", style: .plain, target: nil, action: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Фотки"
        setupCollectionView()
        
        photoItems = appState.photoItems
        appState.$photoItems.sink(receiveValue: {[weak self] photoItems in
            self?.photoItemsReceived(newPhotoItems: photoItems)
        })
        .store(in: &subscriptions)
        
        navigationItem.leftBarButtonItem = firebaseStatusBarItem
        appState.$firebaseIsConnected.sink(receiveValue: {[weak self] firebaseIsConnected in
            self?.firebaseStatusBarItem.title = firebaseIsConnected ? "Онлайн" : "Оффлайн"
            self?.firebaseStatusBarItem.tintColor = firebaseIsConnected ? UIColor.green : UIColor.red
        })
        .store(in: &subscriptions)
    }    
}

// MARK: -  DiffableDataSource
extension PhotoItemListViewController {
    private func photoItemsReceived(newPhotoItems: [PhotoItem]) {
        if newPhotoItems.count > 0 {
            loadingIndicator.stopAnimating()
        }
        photoItems = newPhotoItems
        applySnapshot(animatingDifferences: true)
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        
        let nib = UINib(nibName: PhotoItemCollectionViewCell.reuseIdentifier, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: PhotoItemCollectionViewCell.reuseIdentifier)
    }
    
    enum Section {
        case main
    }
    
    fileprivate typealias DataSource = UICollectionViewDiffableDataSource<Section, PhotoItem>
    
    private func makeDataSource() -> DataSource {
        let dataSource = DataSource(collectionView: collectionView, cellProvider: { (collectionView, indexPath, photoItem) ->
            UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoItemCollectionViewCell.reuseIdentifier, for: indexPath) as! PhotoItemCollectionViewCell
            cell.photoItem = photoItem
            cell.configure()
            return cell
        })
        return dataSource
    }
    
    fileprivate typealias Snapshot = NSDiffableDataSourceSnapshot<Section, PhotoItem>

    private func applySnapshot(animatingDifferences: Bool = true) {
      var snapshot = Snapshot()
      snapshot.appendSections([.main])
      snapshot.appendItems(photoItems)
      dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
    
}


// MARK: -  UICollectionViewDelegate
extension PhotoItemListViewController {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let photoItem = dataSource.itemIdentifier(for: indexPath),
        let _ = photoItem.image else {
          return
        }
        let vc = EditItemViewController(photoItem: photoItem)
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: -  UICollectionViewDelegateFlowLayout
extension PhotoItemListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let widthPerItem = collectionView.frame.width / 2 - 2
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
