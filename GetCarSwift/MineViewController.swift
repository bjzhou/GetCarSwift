//
//  MineViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/4/11.
//  Copyright (c) 2015年 周斌佳. All rights reserved.
//

import UIKit
import RxSwift

class MineViewController: UITableViewController {

    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tableView.reloadData()
    }

    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableView.sectionHeaderHeight
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath) as UITableViewCell
        if indexPath.section == 0 {
            let accountCell = cell as! AccountCell
            accountCell.avatar.layer.masksToBounds = true
            accountCell.avatar.layer.cornerRadius = 8
            accountCell.sexIcon.image = UIImage(named: Me.sharedInstance.sex == 0 ? "mine_female" : "mine_male")
            accountCell.avatar.setAvatarImage()
            accountCell.accountName.text = Me.sharedInstance.nickname ?? "用户名"
            DeviceDataService.sharedInstance.rx_district.bindTo(accountCell.accountDescription.rx_text).addDisposableTo(disposeBag)
            return accountCell
        }
        return cell
    }

}
