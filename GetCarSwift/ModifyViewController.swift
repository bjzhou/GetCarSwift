//
//  ModifyViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/4/11.
//  Copyright (c) 2015年 周斌佳. All rights reserved.
//

import UIKit

class ModifyViewController: UIViewController {
    
    //@IBOutlet weak var jichuButton: UIButton!
    @IBOutlet weak var haohuaButton: UIButton!
    //@IBOutlet weak var baijinButton: UIButton!
    @IBOutlet weak var zhizunButton: UIButton!
    @IBOutlet weak var customButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!

    
    var buttons = [UIButton]()

    override func viewDidLoad() {
        super.viewDidLoad()

        buttons = [haohuaButton, zhizunButton, customButton]
    }
    
    
    @IBAction func onBackAction(sender: UIButton) {
        dismissViewControllerAnimated(false, completion: nil)
    }
    
    @IBAction func onChangeAction(sender: UIButton) {
        if sender.selected {
            return
        }
        
        sender.selected = true
        for button in buttons {
            if button != sender {
                button.selected = false;
            }
        }
        
        UIView.transitionWithView(imageView, duration: 1.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
            if sender == self.haohuaButton {
                self.imageView.image = UIImage(named: IMAGE_YELLOW_CAR)
            } else if sender == self.zhizunButton {
                self.imageView.image = UIImage(named: IMAGE_GRAY_CAR)
            }
            }, completion: nil)

    }
    
    @IBAction func onSaveAction(sender: UIButton) {
        dismissViewControllerAnimated(false, completion: nil)
    }
    
    override func shouldAutorotate() -> Bool {
        return false;
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Landscape
    }
    
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return UIInterfaceOrientation.LandscapeLeft
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

}
