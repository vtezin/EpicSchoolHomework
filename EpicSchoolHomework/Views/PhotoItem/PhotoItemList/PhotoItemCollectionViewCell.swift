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
            
    }
}
