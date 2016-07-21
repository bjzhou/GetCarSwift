//
//  UITableViewController+GK.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/12/7.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import Foundation

extension UITableViewController {

    public override func viewDidLoad() {
        self.clearsSelectionOnViewWillAppear = false
    }

    public override func viewWillAppear(_ animated: Bool) {
        if let indexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}
