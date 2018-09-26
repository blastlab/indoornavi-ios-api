//
//  MenuViewController.swift
//  IndoorNaviDemoDynamicFramework
//
//  Created by Michał Pastwa on 21.09.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

import UIKit

fileprivate let MenuItemCellIdentifier = "MenuItem"
fileprivate let Images = ["area", "info", "localization", "marker", "polyline", "report"]
fileprivate let Titles = ["Draw area", "Draw info window", "Locate", "Place marker", "Draw polyline", "Report"]

class MenuViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rowsCount = Images.count
        return rowsCount
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MenuItemCellIdentifier, for: indexPath) as! MenuTableViewCell
        
        cell.icon.image = UIImage(named: Images[indexPath.row])
        cell.title.text = Titles[indexPath.row]

        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationvc = segue.destination
        if let mapvc = destinationvc.contentViewController as? MapViewController, let row = tableView.indexPathForSelectedRow?.row {
            mapvc.didSelect(optionWithNumber: row)
        }
    }
}

extension UIViewController {
    var contentViewController: UIViewController {
        if let navcon = self as? UINavigationController {
            return navcon.visibleViewController ?? self
        } else {
            return self
        }
    }
}
