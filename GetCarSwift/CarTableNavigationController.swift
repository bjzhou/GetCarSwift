//
//  CarTableNavigationController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/8/14.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import UIKit

protocol CarTableNavigationDelegate {
    func didCarSelected(car: String)
}

class CarTableNavigationController: ENSideMenuNavigationController {

    var carDelegate: CarTableNavigationDelegate?
    var menuController: CarRightTableViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        menuController = CarRightTableViewController()
        menuController?.delegate = self

        sideMenu = ENSideMenu(sourceView: self.view, menuViewController: menuController!, menuPosition:.Right)
        view.bringSubviewToFront(navigationBar)

        sideMenu?.menuWidth = 250
        sideMenu?.bouncingEnabled = false
        sideMenu?.allowLeftSwipe = false
    }

}

extension CarTableNavigationController: CarRightDelegate {
    func didCarSelected(car: String) {
        carDelegate?.didCarSelected(car)
    }

    func dismissViewController() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
