//
//  CustomModifyViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/5/18.
//  Copyright (c) 2015年 &#21608;&#25996;&#20339;. All rights reserved.
//

import UIKit

class CustomModifyViewController: UIViewController {

    @IBOutlet weak var lightButton: UIButton!
    @IBOutlet weak var glassButton: UIButton!
    @IBOutlet weak var lunguButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(animated: Bool) {
        var animateImages = [UIImage(named: "ani_press_1")!, UIImage(named: "ani_press_2")!, UIImage(named: "ani_press_3")!]
        lightButton.imageView?.animationImages = animateImages
        lightButton.imageView?.animationRepeatCount = 0
        lightButton.imageView?.animationDuration = 1
        lightButton.imageView?.startAnimating()
    }

    @IBAction func onLungu1Action(sender: AnyObject) {

    }
    @IBAction func onLungu2Action(sender: AnyObject) {
    }
    @IBAction func onBackAction(sender: AnyObject) {
        dismissViewControllerAnimated(false, completion: nil)
    }
    
    override func shouldAutorotate() -> Bool {
        return false;
    }

    override func supportedInterfaceOrientations() -> Int {
        return UIInterfaceOrientation.LandscapeLeft.rawValue
    }

}
