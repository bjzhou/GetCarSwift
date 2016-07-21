//
//  AboutTableViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/12/1.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import UIKit

class AboutTableViewController: UITableViewController {

    @IBOutlet weak var versionLabel: UILabel!

    let appStoreUrl = "https://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=1038915609&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8"

    var backgroundViewY: CGFloat?

    override func viewDidLoad() {
        super.viewDidLoad()

        versionLabel.text = "V " + versionShort!

        let imageView = UIImageView(image: R.image.about_bg)
        imageView.contentMode = .center
        self.tableView.backgroundView = imageView
    }

    override func viewDidLayoutSubviews() {
        if backgroundViewY == nil {
            backgroundViewY = self.tableView.tableFooterView?.frame.origin.y ?? 0
        }
        let y = self.tableView.contentOffset.y
        self.tableView.backgroundView?.frame = CGRect(x: 0, y: backgroundViewY! + y, width: self.view.frame.width, height: self.view.frame.height - backgroundViewY!)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if (indexPath as NSIndexPath).row == 0 {
            showViewController(R.storyboard.launchScreen.initialViewController!)
        }

        if (indexPath as NSIndexPath).row == 1 {
            UIApplication.shared().openURL(URL(string: appStoreUrl)!)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}
