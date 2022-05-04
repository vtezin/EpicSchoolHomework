//
//  CommentsListViewController.swift
//  EpicSchoolHomework
//
//  Created by Vladimir Tezin on 07.04.2022.
//

import UIKit
import Foundation

final class CommentsListViewController: UIViewController {
    @IBOutlet weak var commentText: UITextView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addCommentStackView: UIStackView!
    
    var photoItem: PhotoItem
    let indexPhotoItemInArray: Int
    let delegate: canUpdatePhotoItemInArray
    
    @IBAction func buttonAddCommenttapped(_ sender: Any) {
        addComment()
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(photoItem: PhotoItem,
         indexPhotoItemInArray: Int,
         delegate: canUpdatePhotoItemInArray) {
        self.photoItem = photoItem
        self.indexPhotoItemInArray = indexPhotoItemInArray
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addCommentStackView.isHidden = !FireBaseService.isConnected
        setupTableView()
        addKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate.updatePhotoItemInArray(photoItem: photoItem,
                                        index: indexPhotoItemInArray)
    }
}

// MARK: -  Functions
extension CommentsListViewController {
    private func addComment() {
        let newComment = PhotoItem.Comment(id: UUID().uuidString,
                                           author: FireBaseService.currentUserName,
                                           text: commentText.text,
                                           date: Date())
                
        photoItem.comments.append(newComment)
        FireBaseService.addComment(photoItem: photoItem,
                                      comment: newComment)
                
        commentText.text = ""
        tableView.reloadData()
        commentText.endEditing(true)
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.tableFooterView = UIView()
        tableView.allowsSelection = false
        
        let nib = UINib(nibName: CommentCellView.reuseIdentifier, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: CommentCellView.reuseIdentifier)
        
        navigationItem.title = photoItem.description
        
        commentText.layer.borderWidth = 0.5;
        commentText.layer.borderColor = UIColor.gray.cgColor;
        commentText.layer.cornerRadius = 5;
        commentText.clipsToBounds = true;
        
        commentText.text = ""
    }
}

// MARK: -  UITableViewDelegate, UITableViewDataSource
extension CommentsListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photoItem.comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let comment = photoItem.comments[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CommentCellView.reuseIdentifier, for: indexPath) as! CommentCellView
        cell.comment = comment
        cell.configureCell()
        
        return cell
    }
}

// MARK: -  keyboard support
extension CommentsListViewController {
    private func addKeyboardNotifications() {
        // call the 'keyboardWillShow' function when the view controller receive notification that keyboard is going to be shown
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        // call the 'keyboardWillHide' function when the view controlelr receive notification that keyboard is going to be hidden
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
           // if keyboard size is not available for some reason, dont do anything
           return
        }
      
      // move the root view up by the distance of keyboard height
      self.view.frame.origin.y = 0 - keyboardSize.height
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        // move back the root view origin to zero
        self.view.frame.origin.y = 0
    }
}
