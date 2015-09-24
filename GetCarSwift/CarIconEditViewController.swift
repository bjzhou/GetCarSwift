//
//  CarIconEditViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/4/18.
//  Copyright (c) 2015年 周斌佳. All rights reserved.
//

import UIKit

class CarIconEditViewController: UIViewController {

    var colorTag = DataKeeper.sharedInstance.carHeadBg
    var iconTag = DataKeeper.sharedInstance.carHeadId
    var prevColorTag = -1
    var prevIconTag = -1

    override func viewDidLoad() {
        super.viewDidLoad()

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
        DataKeeper.sharedInstance.carHeadBg = colorTag
        DataKeeper.sharedInstance.carHeadId = iconTag
        User.updateInfo(color: String(colorTag), icon: String(iconTag)).subscribeNext { res in
            if let user = res.data {
                updateLogin(user)
            }
        }
        self.navigationController?.popViewControllerAnimated(true)
    }

}
