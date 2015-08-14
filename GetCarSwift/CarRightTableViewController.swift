//
//  CarRightTableViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/8/13.
//  Copyright © 2015年 &#21608;&#25996;&#20339;. All rights reserved.
//

import UIKit

protocol CarRightDelegate: CarTableNavigationDelegate {
    func dismissViewController()
}

class CarRightTableViewController: UITableViewController {
    
    var delegate: CarRightDelegate?
    var data: [String] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (data.count) ?? 0
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell?

        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: "cell")
        }
        
        cell?.textLabel?.text = data[indexPath.row]

        return cell!
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let delegate = delegate {
            delegate.didCarSelected(data[indexPath.row])
            delegate.dismissViewController()
        }
    }

}
