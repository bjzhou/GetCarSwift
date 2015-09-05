//
//  CarIconEditViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/4/18.
//  Copyright (c) 2015年 周斌佳. All rights reserved.
//

import UIKit

class CarIconEditViewController: UIViewController {

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
            let image = UIImage(named: getColorIconName(DataKeeper.sharedInstance.sex, color: tag))
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
            let image = UIImage(named: getCarIconName(DataKeeper.sharedInstance.sex, color: colorTag, icon: tag))
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
        UserApi.updateInfo(color: String(colorTag), icon: String(iconTag), completion: {gkResult in
            if let data = gkResult.data {
                updateLogin(data)
            }
        })
        self.navigationController?.popViewControllerAnimated(true)
    }

}
