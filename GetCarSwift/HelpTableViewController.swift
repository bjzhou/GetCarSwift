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
            let now = NSCalendar.currentCalendar().components([.Hour], fromDate: NSDate())
            if now.hour >= 8 && now.hour < 22 {
                let alertController = UIAlertController(title: "联系改客专员", message: nil, preferredStyle: .Alert)
                alertController.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: nil))
                alertController.addAction(UIAlertAction(title: "呼叫", style: .Default, handler: { _ in
                    UIApplication.sharedApplication().openURL(NSURL(string: self.telUrl)!)
                }))
                presentViewController(alertController, animated: true, completion: nil)
            }
        }
    }

}
