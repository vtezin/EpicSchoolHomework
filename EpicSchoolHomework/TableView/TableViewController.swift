//
//  TableViewController.swift
//  EpicSchoolHomework
//
//  Created by Vladimir Tezin on 23.03.2022.
//

import UIKit

// MARK: -  UITableViewController
class TableViewController: UITableViewController {
    private var photoItems = [PhotoItem]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        PhotoItem.fetchDataFromWeb(handler: decodeData)
    }
    
    func decodeData(data: Data) {
        if let photoItems = PhotoItem.decodeDataToPhotoItems(data: data) {
            self.photoItems = photoItems
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    private func setupTableView() {
        tableView.allowsSelection = false
        tableView.separatorColor = .clear
        
        let nib = UINib(nibName: PhotoItemTableViewCell.reuseIdentifier, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: PhotoItemTableViewCell.reuseIdentifier)
    }
}

// MARK: -  UITableViewDelegate
extension TableViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        350
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photoItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let photoItem = photoItems[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: PhotoItemTableViewCell.reuseIdentifier, for: indexPath) as! PhotoItemTableViewCell
        cell.photoItem = photoItem
        cell.configureCell()
        
        print("cellForRowAt \(indexPath.row) - \(photoItem.author)")
        
        return cell
    }    
}
