//
//  PersonInfoViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/4/11.
//  Copyright (c) 2015年 周斌佳. All rights reserved.
//

import UIKit

class PersonInfoViewController: UITableViewController {
    
    let titles = ["头像", "车形象", "用户名", "我的二维码", "我的地址", "性别", "地区", "个性签名"]
    let values = [IMAGE_AVATAR, IMAGE_CAR_IMAGE, "SURA", IMAGE_QRCODE, "", "女", "上海浦东新区", ""]

    override func viewDidLoad() {
        super.viewDidLoad()

        self.clearsSelectionOnViewWillAppear = false
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 5
        } else {
            return 3
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: PersonInfoCell
        if indexPath.section == 0 && (indexPath.row == 0 || indexPath.row == 1 || indexPath.row == 3) {
            cell = tableView.dequeueReusableCellWithIdentifier("info_icon", forIndexPath:indexPath) as! PersonInfoCell
            cell.title.text = titles[indexPath.row]
            cell.icon.image = UIImage(named: values[indexPath.row])
        } else {
            cell = tableView.dequeueReusableCellWithIdentifier("info_text", forIndexPath:indexPath) as! PersonInfoCell
            if indexPath.section == 0 {
                cell.title.text = titles[indexPath.row]
                cell.value.text = values[indexPath.row]
            } else {
                cell.title.text = titles[indexPath.row + 5]
                cell.value.text = values[indexPath.row + 5]
            }
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 && (indexPath.row == 0 || indexPath.row == 1) {
            return 80
        } else {
            return 60
        }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableView.sectionHeaderHeight;
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
