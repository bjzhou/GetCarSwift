//
//  ModifyViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/4/11.
//  Copyright (c) 2015年 周斌佳. All rights reserved.
//

import UIKit

class ModifyViewController: UIViewController {
    
    @IBOutlet weak var jichuButton: UIButton!
    @IBOutlet weak var haohuaButton: UIButton!
    @IBOutlet weak var baijinButton: UIButton!
    @IBOutlet weak var zhizunButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    var buttons = [UIButton]()

    override func viewDidLoad() {
        super.viewDidLoad()

        buttons = [jichuButton, haohuaButton, baijinButton, zhizunButton]
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
        
        if sender == jichuButton {
            UIView.transitionWithView(imageView, duration: 1.5, options: UIViewAnimationOptions.TransitionCurlUp, animations: {
                self.imageView.image = UIImage(named: IMAGE_RED_CAR)
            }, completion: nil)
        }
        
        if sender == haohuaButton {
            UIView.transitionWithView(imageView, duration: 1.5, options: UIViewAnimationOptions.TransitionFlipFromLeft, animations: {
                self.imageView.image = UIImage(named: IMAGE_YELLOW_CAR)
                }, completion: nil)
        }
        
        if sender == baijinButton {
            UIView.transitionWithView(imageView, duration: 1.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
                self.imageView.image = UIImage(named: IMAGE_BLUE_CAR)
                }, completion: nil)
        }
        
        if sender == zhizunButton {
            UIView.transitionWithView(imageView, duration: 1.5, options: UIViewAnimationOptions.TransitionFlipFromTop, animations: {
                self.imageView.image = UIImage(named: IMAGE_GRAY_CAR)
                }, completion: nil)
        }
    }
    
    @IBAction func onSaveAction(sender: UIButton) {
        dismissViewControllerAnimated(false, completion: nil)
    }
    
    override func shouldAutorotate() -> Bool {
        return false;
    }
    
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return UIInterfaceOrientation.LandscapeLeft
    }
    
    override func viewDidAppear(animated: Bool) {
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Slide)
    }
    
    override func viewDidDisappear(animated: Bool) {
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Slide)
    }

}
