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
    @IBOutlet private weak var likesCountLabel: UILabel!
    @IBOutlet private weak var likeButton: UIButton!
    @IBOutlet private weak var heartView: HeartBezierView!
    @IBOutlet weak var photoScrollView: UIScrollView!
    
    @IBOutlet weak var commentsButton: UIButton!
    @IBAction func likeButtonTapped(_ sender: Any) {
        likedToggle()
    }
    @IBAction func commentsButtonTapped(_ sender: Any) {
        navigationToCommentsHandler!(photoItem!, cellIndex)
    }
    
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


// MARK: -  Functions
extension PhotoItemTableViewCell {
    func setImageToCell(uiImage: UIImage?) {
        if let uiImage = uiImage{
            photoItem?.image = uiImage
            photoImageView.image = uiImage
            loadingActivityIndicator.isHidden = true
            RealmService.saveItem(photoItem: self.photoItem!)
        }
    }
    
    func configureCell() {
        selectionStyle = .none
        photoScrollView.clipsToBounds = true
        photoScrollView.layer.cornerRadius = 8
        self.heartView.alpha = 0
        
        ImagesService.fetchImageForPhotoItem(photoItem: photoItem!,
                                      completion: setImageToCell)
        
        authorLabel.text = photoItem!.author
        descriptionLabel.text = photoItem!.description
        commentsButton.setTitle("Комментарии (\(photoItem!.comments.count))", for: .normal)
        
        updateLikesInfo()
        
        let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTappedSingle))
        singleTapGesture.numberOfTapsRequired = 1
        photoImageView.addGestureRecognizer(singleTapGesture)

        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTappedDouble))
        doubleTapGesture.numberOfTapsRequired = 2
        photoImageView.addGestureRecognizer(doubleTapGesture)

        singleTapGesture.require(toFail: doubleTapGesture)
        
        photoImageView.isUserInteractionEnabled = true
        
        photoScrollView.delegate = self
        photoScrollView.minimumZoomScale = 1.0
        photoScrollView.maximumZoomScale = 10.0
        
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
    
    private func updateLikesInfo() {
        likesCountLabel.text = photoItem!.likesFormattedString
        likeButton.alpha = photoItem!.isLikedByCurrentUser ? 1 : 0.3
    }
    
    private func likedToggle() {
        guard FireBaseService.isConnected else {return}
        photoItem!.toggleLikeByUser(userName: FireBaseService.currentUserName)
        FireBaseService.updateLikesInfo(photoItem: photoItem!)
        updateLikesInfo()
    }
    
}
