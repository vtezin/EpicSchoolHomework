//
//  CommentCellViewController.swift
//  EpicSchoolHomework
//
//  Created by Vladimir Tezin on 07.04.2022.
//

import UIKit

final class CommentCellView: UITableViewCell {
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!    
    @IBOutlet weak var dateLabel: UILabel!
    
    static let reuseIdentifier = String(describing: CommentCellView.self)
    
    var comment: PhotoItem.Comment?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        authorLabel.text = ""
        commentLabel.text = ""
        dateLabel.text = ""
    }
    
    func configureCell() {
        selectionStyle = .none
        
        authorLabel.text = comment?.author
        commentLabel.text = comment?.text
        dateLabel.text = comment?.date.stringDescription
    }    
}
