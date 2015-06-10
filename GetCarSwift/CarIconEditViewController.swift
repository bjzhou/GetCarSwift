//
//  CarIconEditViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/4/18.
//  Copyright (c) 2015年 &#21608;&#25996;&#20339;. All rights reserved.
//

import UIKit

class CarIconEditViewController: UIViewController {
    
    var sex = NSUserDefaults.standardUserDefaults().integerForKey("sex")
    var colorTag = NSUserDefaults.standardUserDefaults().integerForKey("color")
    var iconTag = NSUserDefaults.standardUserDefaults().integerForKey("icon")
    var prevColorTag = -1
    var prevIconTag = -1

    override func viewDidLoad() {
        super.viewDidLoad()

        colorTag = colorTag == 0 ? 101 : colorTag
        iconTag = iconTag == 0 ? 201 : iconTag
        loadHighlightButton()
        loadCurrentIcon()
    }
    
    func loadHighlightButton() {
        for tag in 101...109 {
            let button = self.view.viewWithTag(tag) as! UIButton
            let image = UIImage(named: getColorIconName(sex, color: tag))
            button.setImage(image, forState: UIControlState.Highlighted)
            button.setImage(image, forState: [UIControlState.Selected, UIControlState.Highlighted])
            button.setImage(image, forState: UIControlState.Selected)
        }
    }
    
    func loadCurrentIcon() {
        let colorButton = self.view.viewWithTag(colorTag) as! UIButton
        colorButton.selected = true
        
        if prevColorTag != -1 && prevColorTag != colorTag {
            let prevButton = self.view.viewWithTag(prevColorTag) as! UIButton
            prevButton.selected = false
        }
        prevColorTag = colorTag
        
        for tag in 201...206 {
            let button = self.view.viewWithTag(tag) as! UIButton
            let noSexImage = UIImage(named: getNoSexCarIconName(colorTag, icon: tag))
            let image = UIImage(named: getCarIconName(sex, color: colorTag, icon: tag))
            button.setImage(noSexImage, forState: UIControlState.Normal)
            button.setImage(image, forState: UIControlState.Highlighted)
            button.setImage(image, forState: [UIControlState.Selected, UIControlState.Highlighted])
            button.setImage(image, forState: UIControlState.Selected)
        }

        let iconButton = self.view.viewWithTag(iconTag) as! UIButton
        iconButton.selected = true
        
        if prevIconTag != -1 && prevIconTag != iconTag {
            let prevButton = self.view.viewWithTag(prevIconTag) as! UIButton
            prevButton.selected = false
        }
        prevIconTag = iconTag
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onColorAction(sender: UIButton) {
        colorTag = sender.tag
        loadCurrentIcon()
    }

    @IBAction func onIconAction(sender: UIButton) {
        iconTag = sender.tag
        loadCurrentIcon()
    }

    @IBAction func onSaveAction(sender: UIButton) {
        NSUserDefaults.standardUserDefaults().setInteger(colorTag, forKey: "color")
        NSUserDefaults.standardUserDefaults().setInteger(iconTag, forKey: "icon")
        self.navigationController?.popViewControllerAnimated(true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
