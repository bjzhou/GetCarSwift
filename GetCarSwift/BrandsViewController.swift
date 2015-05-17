//
//  BrandsViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/5/17.
//  Copyright (c) 2015年 &#21608;&#25996;&#20339;. All rights reserved.
//

import UIKit

protocol BrandsDelegate {
    func brandChanged(index: Int)
}

class BrandsViewController: UITableViewController {
    
    var delegate: BrandsDelegate?
    var currentBrand = 0

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableView.sectionHeaderHeight
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        currentBrand = indexPath.row
        tableView.reloadData()
        delegate?.brandChanged(currentBrand)
        navigationController?.popViewControllerAnimated(true)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        cell.accessoryView = UIImageView(image: indexPath.row == currentBrand ? UIImage(named: IAMGE_ACCESSORY_SELECTED) : UIImage(named: IAMGE_ACCESSORY))
        return cell
    }

}
