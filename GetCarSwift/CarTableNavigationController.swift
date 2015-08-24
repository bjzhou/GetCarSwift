//
//  CarTableNavigationController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/8/14.
//  Copyright © 2015年 &#21608;&#25996;&#20339;. All rights reserved.
//

import UIKit

protocol CarTableNavigationDelegate {
    func didCarSelected(carName: String)
}

class CarTableNavigationController: ENSideMenuNavigationController, CarRightDelegate {
    
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
    
    func didCarSelected(carName: String) {
        carDelegate?.didCarSelected(carName)
    }
    
    func dismissViewController() {
        dismissViewControllerAnimated(true, completion: nil)
    }

}
