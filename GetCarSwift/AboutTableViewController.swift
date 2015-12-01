//
//  AboutTableViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/12/1.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import UIKit

class AboutTableViewController: UITableViewController {

    let appStoreUrl = "https://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=1038915609&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8"

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        if indexPath.row == 0 {
            showViewController(R.storyboard.launchScreen.initialViewController!)
        }

        if indexPath.row == 1 {
            UIApplication.sharedApplication().openURL(NSURL(string: appStoreUrl)!)
        }
    }
}
