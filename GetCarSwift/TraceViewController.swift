//
//  TraceViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/8/2.
//  Copyright © 2015年 &#21608;&#25996;&#20339;. All rights reserved.
//

import UIKit

class TraceViewController: UIViewController, AccelerationUpdateDelegate {
    @IBOutlet weak var swiftPagesView: SwiftPages!
    
    let VCIDs = ["data", "map"];
    let buttonTitles = ["数据", "地图"];

    override func viewDidLoad() {
        super.viewDidLoad()

        swiftPagesView.initializeWithVCIDsArrayAndButtonTitlesArray(VCIDs, buttonTitlesArray: buttonTitles)
        swiftPagesView.enableBarShadow(true)
    }
    
    override func viewDidAppear(animated: Bool) {
        if let dataVC = swiftPagesView.getPageViewController(0) as? DataViewController {
            dataVC.delegate = self
        }
    }
    
    func onLeft() {
        swiftPagesView.switchPage(0)
    }
    
    func onRight() {
        swiftPagesView.switchPage(1)
    }

}
