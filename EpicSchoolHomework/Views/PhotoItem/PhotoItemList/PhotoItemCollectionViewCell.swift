//
//  PhotoItemCollectionViewCell.swift
//  EpicSchoolHomework
//
//  Created by Vladimir Tezin on 08.06.2022.
//

import UIKit

final class PhotoItemCollectionViewCell: UICollectionViewCell {
    static var reuseIdentifier = "PhotoItemCollectionViewCell"
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    @IBOutlet private weak var likesStackView: UIStackView!
    @IBOutlet private weak var likesCountLabel: UILabel!
    @IBOutlet private weak var likesImageView: UIImageView!
    
    @IBOutlet private weak var commentsStackView: UIStackView!
    @IBOutlet private weak var commentsCountLabel: UILabel!
    @IBOutlet private weak var commentsImageView: UIImageView!
    
    @IBOutlet private weak var visitsStackView: UIStackView!
    @IBOutlet private weak var visitsCountLabel: UILabel!
    @IBOutlet private weak var visitsImageView: UIImageView!
    
    var photoItem: PhotoItem?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func prepareForReuse() {
        imageView.image = nil
    }
}

// MARK: -  Functions
extension PhotoItemCollectionViewCell{
    func configure() {
        guard let photoItem = photoItem else {return}
        
        descriptionLabel.text = photoItem.description
        
        if let image = photoItem.image {
            imageView.image = image
            loadingIndicator.stopAnimating()
        } else {
            loadingIndicator.startAnimating()
        }
            
        likesStackView.isHidden = photoItem.likes.count == 0
        commentsStackView.isHidden = photoItem.comments.count == 0
        visitsStackView.isHidden = photoItem.visits.count == 0
        
        likesCountLabel.text = String("\(photoItem.likes.count)");
        commentsCountLabel.text = String("\(photoItem.comments.count)");
        visitsCountLabel.text = String("\(photoItem.visits.count)");
        
        likesImageView.image = UIImage(systemName: photoItem.isLikedByCurrentUser ? "hand.thumbsup.fill" : "hand.thumbsup" )
        visitsImageView.image = UIImage(systemName: photoItem.isVisitedByCurrentUser ? "eye.fill" : "eye" )
    }
}
