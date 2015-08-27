//
//  TraceViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/8/2.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import UIKit

class TraceViewController: UIViewController {
    @IBOutlet weak var swiftPagesView: SwiftPages!
    
    var a:Double = 0

    let VCIDs = ["data", "map"];
    let buttonTitles = ["数据", "地图"];

    override func viewDidLoad() {
        super.viewDidLoad()

        swiftPagesView.initializeWithVCIDsArrayAndButtonTitlesArray(VCIDs, buttonTitlesArray: buttonTitles, sender: self)
    }

}
