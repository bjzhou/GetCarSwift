//
//  HelpTableViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/12/1.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import UIKit

class HelpTableViewController: UITableViewController {

    let telUrl = "tel://15921874027"

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        if indexPath.row == 0 {
            UIApplication.sharedApplication().openURL(NSURL(string: telUrl)!)
        }
    }

}
