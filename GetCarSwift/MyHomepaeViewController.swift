//
//  MyHomepaeViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/5/14.
//  Copyright (c) 2015年 周斌佳. All rights reserved.
//

import UIKit

class MyHomepaeViewController: UIViewController {

    @IBOutlet weak var collectCount: UILabel!
    @IBOutlet weak var postCount: UILabel!
    @IBOutlet weak var position: UILabel!
    @IBOutlet weak var nickname: UILabel!
    @IBOutlet weak var sexImage: UIImageView!
    @IBOutlet weak var myAvatar: UIImageView!
    @IBOutlet weak var homepageBg: UIImageView!

    var district: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        myAvatar.setAvatarImage()
        sexImage.image = UIImage(named: DataKeeper.sharedInstance.sex == 0 ? "mine_female" : "mine_male")
        nickname.text = DataKeeper.sharedInstance.nickname
        position.text = district ?? "正在获取位置"
    }

    override func viewWillAppear(animated: Bool) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let index = userDefaults.integerForKey("homepage_bg")
        if index == 1000 {
            imageCache.fetch(key: "homepage_bg").onSuccess {image in
                self.homepageBg.image = image
            }
        } else {
            homepageBg.image = UIImage(named: getHomepageBg(index == 0 ? 1 : index))
        }
    }
}
