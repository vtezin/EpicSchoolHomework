//
//  MainScreenViewController.swift
//  EpicSchoolHomework
//
//  Created by Vladimir Tezin on 06.04.2022.
//

import UIKit
import Firebase

final class MainScreenViewController: UIViewController {    
    @IBOutlet weak var refreshLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingActivityController: UIActivityIndicatorView!
    
    private var photoItems = [PhotoItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let addPhotoMenu = UIMenu(title: "", children: [
            UIAction(title: "Камера", image: UIImage(systemName: "camera")){
                action in
                self.addNewItem(fromCamera: true)
            },
            UIAction(title: "Фотопленка", image: UIImage(systemName: "photo")){
                action in
                self.addNewItem(fromCamera: false)
            }
        ])
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(systemItem: .add, primaryAction: nil, menu: addPhotoMenu)
        
        setupTableView()
        
        let connectedRef = Database.database().reference(withPath: ".info/connected")
        connectedRef.observe(.value, with: { snapshot in
          if snapshot.value as? Bool ?? false {
              self.refreshLabel.text = "Онлайн"
              self.refreshLabel.textColor = .green
              self.navigationItem.rightBarButtonItem?.isEnabled = true
          } else {
              self.refreshLabel.text = "Оффлайн"
              self.refreshLabel.textColor = .red
              self.navigationItem.rightBarButtonItem?.isEnabled = false
          }
            DataService.fetchPhotoItems(handler: self.photoItemsFetched)
        })
        
        let itemsRef = Database.database().reference().child("photos")
        itemsRef.observe(DataEventType.value, with: { snapshot in
            DataService.fetchPhotoItems(handler: self.photoItemsFetched)
        })
    }
}

// MARK: -  Functions
extension MainScreenViewController {
    private func addNewItem(fromCamera: Bool) {
        let vc = EditItemViewController()
        vc.takeNewPhotoFromCamera = fromCamera
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func photoItemsFetched(photoItems: [PhotoItem]) {
        self.photoItems = photoItems
        DispatchQueue.main.async {
            self.tableView.refreshControl?.endRefreshing()
            //self.refreshLabel.isHidden = true
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
        300
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let photoItem = photoItems[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: PhotoItemTableViewCell.reuseIdentifier, for: indexPath) as! PhotoItemTableViewCell
        cell.photoItem = photoItem
        cell.cellIndex = indexPath.row
        cell.navigationHandler = navigateToComments
        cell.configureCell()
        
        return cell
    }    
}

// MARK: -  canUpdatePhotoItemInArray
extension MainScreenViewController: canUpdatePhotoItemInArray {
    func updatePhotoItemInArray(photoItem: PhotoItem, index: Int) {
        if 0...photoItems.count - 1 ~= index {
            photoItems[index] = photoItem
            tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        }
    }
}
