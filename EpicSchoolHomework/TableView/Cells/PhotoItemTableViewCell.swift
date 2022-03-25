//
//  PhotoItemTableViewCell.swift
//  EpicSchoolHomework
//
//  Created by Vladimir Tezin on 23.03.2022.
//

import UIKit

// MARK: -  PhotoItemTableViewCell
final class PhotoItemTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var photoImageView: UIImageView!
    
    @IBOutlet private weak var authorLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var likesCountLabel: UILabel!
    @IBOutlet private weak var likeButton: UIButton!
    @IBOutlet private weak var heartView: HeartBezierView!
    
    @IBAction func likeButtonTapped(_ sender: Any) {
        likedToggle()
    }
    
    var photoItem: PhotoItem?
    
    static let reuseIdentifier = String(describing: PhotoItemTableViewCell.self)
    
}

// MARK: -  Functions
extension PhotoItemTableViewCell {
    
    func configureCell() {
        selectionStyle = .none
        photoImageView.clipsToBounds = true
        photoImageView.layer.cornerRadius = 8
        self.heartView.alpha = 0
        
        if let photoItem = photoItem {
            photoImageView.image = photoItem.image
            
            authorLabel.text = photoItem.autor
            descriptionLabel.text = photoItem.description
            
            updateLikesInfo()
        }
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        tapGestureRecognizer.numberOfTapsRequired = 2
        
        photoImageView.isUserInteractionEnabled = true
        photoImageView.addGestureRecognizer(tapGestureRecognizer)
        
    }
    
    @objc private func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        likedToggle()
    }
    
    private func updateLikesInfo() {
        if let photoItem = photoItem {
            likesCountLabel.text = photoItem.likesCountDescription
            likeButton.alpha = photoItem.liked ? 1 : 0.3
        }
    }
    
    private func likedToggle() {
        
        heartView.alpha = 1

        PhotoItemTableViewCell.animate(withDuration: 1.0) {
            self.heartView.alpha = 0
        }
        
        photoItem?.likedToggle()
        updateLikesInfo()
    }
    
}
