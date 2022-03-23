//
//  PhotoItemTableViewCell.swift
//  EpicSchoolHomework
//
//  Created by Vladimir Tezin on 23.03.2022.
//

import UIKit

final class PhotoItemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var likesCountLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    
    @IBAction func likeButtonTapped(_ sender: Any) {
        photoItem?.likedToggle()
        updateLikesInfo()
    }
    
    var photoItem: PhotoItem?
    
    static let reuseIdentifier = String(describing: PhotoItemTableViewCell.self)
    
    func configure() {
        
        photoImageView.clipsToBounds = true
        photoImageView.layer.cornerRadius = 8
        
        if let photoItem = photoItem {
            photoImageView.image = photoItem.image
            
            authorLabel.text = photoItem.autor
            descriptionLabel.text = photoItem.description
            
            updateLikesInfo()
        }
        
        selectionStyle = .none
        
    }
    
    func updateLikesInfo() {
        if let photoItem = photoItem {
            likesCountLabel.text = photoItem.likesCountDescription
            likeButton.alpha = photoItem.liked ? 1 : 0.3
        }
    }
    
}
