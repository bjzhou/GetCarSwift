//
//  ModViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/8/8.
//  Copyright © 2015年 &#21608;&#25996;&#20339;. All rights reserved.
//

import UIKit

class ModViewController: UIViewController {
    
    let VCIDs = ["modDoctor", "modStore"]
    let buttonTitles = ["改装博士", "改装商城"]

    @IBOutlet var swiftPagesView: SwiftPages!
    override func viewDidLoad() {
        super.viewDidLoad()

        swiftPagesView.initializeWithVCIDsArrayAndButtonTitlesArray(VCIDs, buttonTitlesArray: buttonTitles, sender: self)
    }
    
    func showViewController(vc: UIViewController) {
        self.showViewController(vc, sender: self)
    }

}

