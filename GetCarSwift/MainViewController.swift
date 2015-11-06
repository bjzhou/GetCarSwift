//
//  MainViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/9/26.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import UIKit

class MainViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.addChildViewController(R.storyboard.trace.initialViewController!)
        self.addChildViewController(R.storyboard.mod.initialViewController!)
        self.addChildViewController(R.storyboard.carBar.initialViewController!)
        self.addChildViewController(R.storyboard.mine.initialViewController!)

        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor()], forState:.Normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.gaikeRedColor()], forState:.Selected)

    }

    override func viewDidLayoutSubviews() {
        for item in self.tabBar.items! {
            item.image = item.image?.imageWithRenderingMode(.AlwaysOriginal)
        }
    }
}
