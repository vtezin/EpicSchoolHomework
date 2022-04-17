//
//  CommentCellViewController.swift
//  EpicSchoolHomework
//
//  Created by Vladimir Tezin on 07.04.2022.
//

import UIKit

class CommentCellView: UITableViewCell {
    
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    static let reuseIdentifier = String(describing: CommentCellView.self)
    
    var comment: PhotoItem.Comment?
    
    func configureCell() {
        selectionStyle = .none
        
        authorLabel.text = comment?.author
        commentLabel.text = comment?.text
    }
    
}
