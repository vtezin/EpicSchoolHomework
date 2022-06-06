//
//  LocalPhotoCollectionViewCell.swift
//  EpicSchoolHomework
//
//  Created by Vladimir Tezin on 06.06.2022.
//

import UIKit

final class LocalPhotoCollectionViewCell: UICollectionViewCell {
    @IBOutlet private weak var imageView: UIImageView!
    var localPhoto: LocalPhoto?
    
    static var reuseIdentifier = "LocalPhotoCollectionViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
}

// MARK: -  Functions
extension LocalPhotoCollectionViewCell{
    func configure() {
        if let localPhoto = localPhoto {
            imageView.image = localPhoto.image
        }
    }
}
