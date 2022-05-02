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
        navigationHandler!(photoItem!, cellIndex)
    }
    
    var photoItem: PhotoItem?
    var cellIndex: Int = 0
    var navigationHandler: ((PhotoItem, Int) -> Void)? = nil
    
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
            RealmController.saveItem(photoItem: self.photoItem!)
        }
    }
    
    func configureCell() {
        selectionStyle = .none
        photoScrollView.clipsToBounds = true
        photoScrollView.layer.cornerRadius = 8
        self.heartView.alpha = 0
        
        ImagesController.fetchImageForPhotoItem(photoItem: photoItem!,
                                      completion: setImageToCell)
        
        authorLabel.text = photoItem!.author
        descriptionLabel.text = photoItem!.description
        commentsButton.setTitle("Комментарии (\(photoItem!.comments.count))", for: .normal)
        
        updateLikesInfo()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        tapGestureRecognizer.numberOfTapsRequired = 2
        
        photoImageView.isUserInteractionEnabled = true
        photoImageView.addGestureRecognizer(tapGestureRecognizer)
        
        photoScrollView.delegate = self
        photoScrollView.minimumZoomScale = 1.0
        photoScrollView.maximumZoomScale = 10.0
        
    }
    
    @objc private func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        heartView.alpha = 1
        PhotoItemTableViewCell.animate(withDuration: 1.0) {
            self.heartView.alpha = 0
        }
        likedToggle()
    }
    
    private func updateLikesInfo() {
        likesCountLabel.text = photoItem!.likesFormattedString
        likeButton.alpha = photoItem!.liked ? 1 : 0.3
    }
    
    private func likedToggle() {
        photoItem!.likedToggle()
        updateLikesInfo()
    }
    
}
