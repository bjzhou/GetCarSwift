//
//  MineViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/4/11.
//  Copyright (c) 2015年 周斌佳. All rights reserved.
//

import UIKit

class MineViewController: UITableViewController {
    
    let titles = ["我的小科", "系统设置", "意见反馈"]
    let images = [IMAGE_XIAO_KE, IMAGE_MINE_SETTINGS, IMAGE_MINE_FEEDBACK]

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1;
        case 1:
            return 1;
        case 2:
            return 2;
        default:
            return 0;
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            var cell = tableView.dequeueReusableCellWithIdentifier("account") as! AccountCell
            cell.avatar.layer.masksToBounds = true
            cell.avatar.layer.cornerRadius = 8
            cell.avatar.image = UIImage(contentsOfFile: getFilePath("avatar"))
            cell.accountName.text = "SURA"
            cell.accountDescription.text = "上海市浦东新区"
            return cell
        } else {
            var cell = tableView.dequeueReusableCellWithIdentifier("common") as! CommonTableViewCell
            switch indexPath.section {
            case 1:
                cell.icon.image = UIImage(named: images[0])
                cell.title.text = titles[0]
            case 2:
                if indexPath.row == 0 {
                    cell.icon.image = UIImage(named: images[1])
                    cell.title.text = titles[1]
                } else {
                    cell.icon.image = UIImage(named: images[2])
                    cell.title.text = titles[2]
                }
            default:
                break
            }
            
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 118
        } else {
            return 60
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var toViewController: UIViewController?
        if indexPath.section == 0 {
            toViewController = storyboard.instantiateViewControllerWithIdentifier("person_info") as? UIViewController
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                toViewController = storyboard.instantiateViewControllerWithIdentifier("mycar") as? UIViewController
            }
        }
        
        if toViewController != nil {
            toViewController!.hidesBottomBarWhenPushed = true;
            navigationController?.showViewController(toViewController!, sender: self)
        }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableView.sectionHeaderHeight
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
