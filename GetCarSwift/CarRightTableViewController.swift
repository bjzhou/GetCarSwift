//
//  CarRightTableViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/8/13.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import UIKit

protocol CarRightDelegate: CarTableNavigationDelegate {
    func dismissViewController()
}

class CarRightTableViewController: UITableViewController {

    var delegate: CarRightDelegate?
    var data: [CarInfo] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (data.count) ?? 0
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")

        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        }

        cell?.textLabel?.text = data[(indexPath as NSIndexPath).row].model

        return cell!
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let delegate = delegate {
            delegate.didCarSelected(data[(indexPath as NSIndexPath).row])
            delegate.dismissViewController()
        }
    }

}
