//
//  ModViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/8/8.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import UIKit

class ModViewController: UIViewController {
    
    let VCIDs = ["modDoctor", "modStore"]
    let buttonTitles = ["改装博士", "改装商城"]

    @IBOutlet var swiftPagesView: SwiftPages!
    override func viewDidLoad() {
        super.viewDidLoad()

        swiftPagesView.initializeWithVCIDsArrayAndButtonTitlesArray(mainStoryboard, VCIDsArray: VCIDs, buttonTitlesArray: buttonTitles, sender: self)
    }

}

