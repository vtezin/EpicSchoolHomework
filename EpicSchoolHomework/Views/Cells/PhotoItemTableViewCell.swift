//
//  PhotoItemTableViewCell.swift
//  EpicSchoolHomework
//
//  Created by Vladimir Tezin on 23.03.2022.
//

import UIKit

// MARK: -  PhotoItemTableViewCell
final class PhotoItemTableViewCell: UITableViewCell, UIScrollViewDelegate {
    @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var photoImageView: UIImageView!
    @IBOutlet private weak var authorLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var heartView: HeartBezierView!
    @IBOutlet private weak var photoScrollView: UIScrollView!

    @IBOutlet private weak var infoStackView: UIStackView!
    @IBOutlet private weak var likesStackView: UIStackView!
    @IBOutlet private weak var likesCountLabel: UILabel!
    @IBOutlet private weak var likesImageView: UIImageView!
    
    @IBOutlet private weak var commentsStackView: UIStackView!
    @IBOutlet private weak var commentsCountLabel: UILabel!
    @IBOutlet weak var commentsImageView: UIImageView!
    
    @IBOutlet private weak var visitsStackView: UIStackView!
    @IBOutlet private weak var visitsCountLabel: UILabel!
    @IBOutlet private weak var visitsImageView: UIImageView!
    
    var photoItem: PhotoItem?
    var cellIndex: Int = 0
    var navigationToCommentsHandler: ((PhotoItem, Int) -> Void)? = nil
    var navigationToPhotoItemHandler: ((PhotoItem, Int) -> Void)? = nil
    
    static let reuseIdentifier = String(describing: PhotoItemTableViewCell.self)
}

// MARK: -  UITableViewCell
extension PhotoItemTableViewCell {
    override func prepareForReuse() {
        super.prepareForReuse()
        photoImageView.image = nil
    }
}

// MARK: -  UIScrollViewDelegate
extension PhotoItemTableViewCell{
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return photoImageView
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        scrollView.zoomScale = 1.0
    }
}

// MARK: -  Gestures
extension PhotoItemTableViewCell {
    private func setGestures() {
        let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTappedSingle))
        singleTapGesture.numberOfTapsRequired = 1
        photoImageView.addGestureRecognizer(singleTapGesture)
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTappedDouble))
        doubleTapGesture.numberOfTapsRequired = 2
        photoImageView.addGestureRecognizer(doubleTapGesture)
        
        singleTapGesture.require(toFail: doubleTapGesture)
        
        let infoSingleTapGesture = UITapGestureRecognizer(target: self, action: #selector(infoStackViewTapped))
        infoSingleTapGesture.numberOfTapsRequired = 1
        infoStackView.addGestureRecognizer(infoSingleTapGesture)
    }
    
    @objc private func imageTappedSingle()
    {
        navigationToPhotoItemHandler!(photoItem!, cellIndex)
    }
    
    @objc private func imageTappedDouble()
    {
        guard FireBaseService.isConnected else {return}
        heartView.alpha = 1
        PhotoItemTableViewCell.animate(withDuration: 1.0) {
            self.heartView.alpha = 0
        }
        likedToggle()
    }
    
    @objc private func infoStackViewTapped()
    {
        navigationToCommentsHandler!(photoItem!, cellIndex)
    }
}

// MARK: -  Functions
extension PhotoItemTableViewCell {
    func setImageToCell(uiImage: UIImage?) {
        if let uiImage = uiImage{
            photoItem?.image = uiImage
            photoImageView.image = uiImage
            loadingActivityIndicator.stopAnimating()
            RealmService.saveItem(photoItem: self.photoItem!)
        }
    }
    
    func configureCell() {
        selectionStyle = .none
        photoScrollView.clipsToBounds = true
        //photoScrollView.layer.cornerRadius = 8
        self.heartView.alpha = 0
        
        loadingActivityIndicator.startAnimating()
        ImagesService.fetchImageForPhotoItem(photoItem: photoItem!,
                                      completion: setImageToCell)
        
        authorLabel.text = "© \(photoItem!.author)"
        descriptionLabel.text = photoItem!.description
        
        updateInfo()
        
        setGestures()
        
        photoScrollView.delegate = self
        photoScrollView.minimumZoomScale = 1.0
        photoScrollView.maximumZoomScale = 10.0
        
    }
    
    private func updateInfo() {
        guard let photoItem = photoItem else {
            return
        }
        
        likesCountLabel.text = String("\(photoItem.likes.count)");
        commentsCountLabel.text = String("\(photoItem.comments.count)");
        visitsCountLabel.text = String("\(photoItem.visits.count)");
        
        likesImageView.image = UIImage(systemName: photoItem.isLikedByCurrentUser ? "hand.thumbsup.fill" : "hand.thumbsup" )
        visitsImageView.image = UIImage(systemName: photoItem.isVisitedByCurrentUser ? "eye.fill" : "eye" )
    }
    
    private func likedToggle() {
        guard FireBaseService.isConnected else {return}
        photoItem!.setLikedByCurrentUser(!photoItem!.isLikedByCurrentUser)
        updateInfo()
    }
    
}
