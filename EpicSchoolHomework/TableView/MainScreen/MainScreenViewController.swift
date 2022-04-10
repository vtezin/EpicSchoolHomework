//
//  MainScreenViewController.swift
//  EpicSchoolHomework
//
//  Created by Vladimir Tezin on 06.04.2022.
//

import UIKit

final class MainScreenViewController: UIViewController {
    
    @IBOutlet weak var refreshLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingActivityController: UIActivityIndicatorView!
    
    private var photoItems = [PhotoItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        refreshLabel.text = "Loading data..."
        PhotoItem.fetchDataFromWeb(numberOfItems: 5, handler: decodeData)
    }
    
    func decodeData(data: Data) {
        if let photoItems = PhotoItem.decodeDataToPhotoItems(data: data) {
            self.photoItems.insert(contentsOf: photoItems, at: 0)
            DispatchQueue.main.async {
                self.tableView.refreshControl?.endRefreshing()
                self.refreshLabel.isHidden = true
                self.loadingActivityController.isHidden = true
                self.tableView.reloadData()
                self.tableView.refreshControl = UIRefreshControl()
                self.tableView.refreshControl?.addTarget(self, action: #selector(self.callPullToRefresh), for: .valueChanged)
            }
        }
    }
    
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.tableFooterView = UIView()
        //tableView.allowsSelection = false
        tableView.separatorColor = .clear
        
        let nib = UINib(nibName: PhotoItemTableViewCell.reuseIdentifier, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: PhotoItemTableViewCell.reuseIdentifier)
        
        navigationItem.title = "Photos"
        
    }
    
    @objc func callPullToRefresh(){
        PhotoItem.fetchDataFromWeb(numberOfItems: 1, handler: decodeData)
    }
    
    func navigateToComments(photoItem: PhotoItem, cellIndex: Int) {
        let vc = CommentsListViewController(photoItem: photoItem,
                                            indexPhotoItemInArray: cellIndex,
                                            delegate: self)
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

// MARK: -  UITableViewDelegate, UITableViewDataSource

extension MainScreenViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photoItems.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        350
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let photoItem = photoItems[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: PhotoItemTableViewCell.reuseIdentifier, for: indexPath) as! PhotoItemTableViewCell
        cell.photoItem = photoItem
        cell.configureCell()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let photoItem = photoItems[indexPath.row]
        navigateToComments(photoItem: photoItem, cellIndex: indexPath.row)
    }
    
}

extension MainScreenViewController: canUpdatePhotoItemInArray {
    func updatePhotoItemInArray(photoItem: PhotoItem, index: Int) {
        if 0...photoItems.count - 1 ~= index {
            photoItems[index] = photoItem
        }
    }
}
