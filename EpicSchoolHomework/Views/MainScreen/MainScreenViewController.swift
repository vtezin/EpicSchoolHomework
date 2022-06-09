//
//  MainScreenViewController.swift
//  EpicSchoolHomework
//
//  Created by Vladimir Tezin on 06.04.2022.
//

import UIKit
import Firebase

final class MainScreenViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingActivityController: UIActivityIndicatorView!
    
    private var photoItems = [PhotoItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
}

// MARK: -  Functions
extension MainScreenViewController {
    func photoItemsFetched(photoItems: [PhotoItem]) {
        self.photoItems = photoItems
        DispatchQueue.main.async {
            self.tableView.refreshControl?.endRefreshing()
            self.loadingActivityController.isHidden = true
            self.tableView.reloadData()
            self.tableView.refreshControl = UIRefreshControl()
            self.tableView.refreshControl?.addTarget(self, action: #selector(self.callPullToRefresh), for: .valueChanged)
        }
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.tableFooterView = UIView()
        tableView.allowsSelection = false
        tableView.separatorColor = .clear
        
        let nib = UINib(nibName: PhotoItemTableViewCell.reuseIdentifier, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: PhotoItemTableViewCell.reuseIdentifier)
        
        navigationItem.title = "Фотки"
    }
    
    @objc private func callPullToRefresh(){
        DataService.fetchPhotoItems(handler: photoItemsFetched)
    }
    
    private func navigateToComments(photoItem: PhotoItem, cellIndex: Int) {
        let vc = CommentsListViewController(photoItem: photoItem)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func navigateToPhotoItem(photoItem: PhotoItem, cellIndex: Int) {
        let vc = EditItemViewController(photoItem: photoItem)
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

// MARK: -  UITableViewDelegate, UITableViewDataSource
extension MainScreenViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photoItems.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        300
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let photoItem = photoItems[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: PhotoItemTableViewCell.reuseIdentifier, for: indexPath) as! PhotoItemTableViewCell
        cell.photoItem = photoItem
        cell.cellIndex = indexPath.row
        cell.navigationToCommentsHandler = navigateToComments
        cell.navigationToPhotoItemHandler = navigateToPhotoItem
        cell.configureCell()
        
        return cell
    }    
}
