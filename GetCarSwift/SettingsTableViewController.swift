//
//  SettingsTableViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/11/25.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var closeDanmu: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()

        closeDanmu.setOn(NSUserDefaults.standardUserDefaults().boolForKey("closeDanmu"), animated: false)
        _ = closeDanmu.rx_value.subscribeNext { on in
            NSUserDefaults.standardUserDefaults().setBool(on, forKey: "closeDanmu")
        }
    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        if indexPath.section == 2 {
            Mine.sharedInstance.logout()
        }
    }

}
