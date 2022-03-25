//
//  TableViewController.swift
//  EpicSchoolHomework
//
//  Created by Vladimir Tezin on 23.03.2022.
//

import UIKit

// MARK: -  UITableViewController
class TableViewController: UITableViewController {
    private let photoItems = PhotoItem.testData

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
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
        300
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photoItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let photoItem = photoItems[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: PhotoItemTableViewCell.reuseIdentifier, for: indexPath) as! PhotoItemTableViewCell
        cell.photoItem = photoItem
        cell.configureCell()
        
        return cell
    }
    
}
