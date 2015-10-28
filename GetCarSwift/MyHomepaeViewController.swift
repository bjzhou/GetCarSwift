//
//  MyHomepaeViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/5/14.
//  Copyright (c) 2015年 周斌佳. All rights reserved.
//

import UIKit
import Haneke
import RxSwift

class MyHomepaeViewController: UIViewController {

    let disposeBag = DisposeBag()

    @IBOutlet weak var collectCount: UILabel!
    @IBOutlet weak var postCount: UILabel!
    @IBOutlet weak var position: UILabel!
    @IBOutlet weak var nickname: UILabel!
    @IBOutlet weak var sexImage: UIImageView!
    @IBOutlet weak var myAvatar: UIImageView!
    @IBOutlet weak var homepageBg: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        myAvatar.setAvatarImage()
        sexImage.image = Me.sharedInstance.sex == 0 ? R.image.mine_female : R.image.mine_male
        nickname.text = Me.sharedInstance.nickname
        DeviceDataService.sharedInstance.rx_district.bindTo(position.rx_text).addDisposableTo(disposeBag)
    }

    override func viewWillAppear(animated: Bool) {
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
}
