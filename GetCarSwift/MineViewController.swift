//
//  MineViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/4/11.
//  Copyright (c) 2015年 周斌佳. All rights reserved.
//

import UIKit
import Haneke
import RxSwift

class MineViewController: UITableViewController {

    @IBOutlet weak var position: UILabel!
    @IBOutlet weak var nickname: UILabel!
    @IBOutlet weak var sexImage: UIImageView!
    @IBOutlet weak var myAvatar: UIImageView!
    @IBOutlet weak var homepageBg: UIImageView!

    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        myAvatar.setAvatarImage()
        sexImage.image = Mine.sharedInstance.sex == 0 ? R.image.mine_female : R.image.mine_male
        nickname.text = Mine.sharedInstance.nickname
        DeviceDataService.sharedInstance.rxDistrict.bindTo(position.rx_text).addDisposableTo(disposeBag)

        myAvatar.layer.masksToBounds = true
        myAvatar.layer.cornerRadius = 10
        myAvatar.layer.borderColor = UIColor.whiteColor().CGColor
        myAvatar.layer.borderWidth = 2
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "didTapHomepageBg")
        tapRecognizer.numberOfTapsRequired = 1
        homepageBg.addGestureRecognizer(tapRecognizer)
    }

    func didTapHomepageBg() {
        showViewController(R.storyboard.mine.bg_choice!)
    }

    override func viewWillAppear(animated: Bool) {
        self.tableView.reloadData()

        let userDefaults = NSUserDefaults.standardUserDefaults()
        let index = userDefaults.integerForKey("homepage_bg")
        if index == 1000 {
            Shared.imageCache.fetch(key: "homepage_bg").onSuccess {image in
                self.homepageBg.image = image
            }
        } else {
            homepageBg.image = UIImage(named: getHomepageBg(index == 0 ? 1 : index))
        }
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableView.sectionHeaderHeight
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath) as UITableViewCell
        return cell
    }

}
