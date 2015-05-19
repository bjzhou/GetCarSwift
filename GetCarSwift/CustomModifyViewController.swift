//
//  CustomModifyViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/5/18.
//  Copyright (c) 2015年 &#21608;&#25996;&#20339;. All rights reserved.
//

import UIKit

class CustomModifyViewController: UIViewController {

    @IBOutlet weak var bgImage: UIImageView!
    @IBOutlet weak var lightButton: UIButton!
    @IBOutlet weak var glassButton: UIButton!
    @IBOutlet weak var lunguButton: UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(animated: Bool) {
        buttonAnimate(lightButton)
        buttonAnimate(glassButton)
    }
    
    func buttonAnimate(button: UIButton!) {
        var animateImages = [UIImage(named: "ani_press_1")!, UIImage(named: "ani_press_2")!, UIImage(named: "ani_press_3")!]
        button.imageView?.animationImages = animateImages
        button.imageView?.animationRepeatCount = 0
        button.imageView?.animationDuration = 1
        button.imageView?.startAnimating()
    }
    @IBAction func onSelectParts(sender: UIButton) {
        sender.imageView?.stopAnimating()
        sender.selected = true
        
        for button in [lightButton,glassButton,lunguButton] {
            if sender != button {
                button.selected = false
                buttonAnimate(button)
            }
        }
    }

    @IBAction func onLunguAction(sender: UIButton) {
        sender.selected = true
        UIView.transitionWithView(bgImage, duration: 1.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
            self.bgImage.image = UIImage(named: "keluzi_lungu_\(sender.tag)")
            }, completion: nil)
        var otherButton = self.view.viewWithTag(sender.tag == 1 ? 2 : 1) as? UIButton
        otherButton?.selected = false
    }

    @IBAction func onBackAction(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func shouldAutorotate() -> Bool {
        return false;
    }

    override func supportedInterfaceOrientations() -> Int {
        return UIInterfaceOrientation.LandscapeLeft.rawValue
    }

}
