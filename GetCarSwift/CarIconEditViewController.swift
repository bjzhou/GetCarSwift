//
//  CarIconEditViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/4/18.
//  Copyright (c) 2015年 周斌佳. All rights reserved.
//

import UIKit
import RxSwift

class CarIconEditViewController: UIViewController {

    let disposeBag = DisposeBag()

    var colorTag = Mine.sharedInstance.carHeadBg
    var iconTag = Mine.sharedInstance.carHeadId
    var prevColorTag = -1
    var prevIconTag = -1

    override func viewDidLoad() {
        super.viewDidLoad()

        loadHighlightButton()
        loadCurrentIcon()
    }

    func loadHighlightButton() {
        for tag in 101...109 {
            let button = self.view.viewWithTag(tag) as? UIButton
            let image = UIImage(named: getColorIconName(Mine.sharedInstance.sex, color: tag))
            button?.setImage(image, for: UIControlState.highlighted)
            button?.setImage(image, for: [UIControlState.selected, UIControlState.highlighted])
            button?.setImage(image, for: UIControlState.selected)
        }
    }

    func loadCurrentIcon() {
        let colorButton = self.view.viewWithTag(colorTag) as? UIButton
        colorButton?.isSelected = true

        if prevColorTag != -1 && prevColorTag != colorTag {
            let prevButton = self.view.viewWithTag(prevColorTag) as? UIButton
            prevButton?.isSelected = false
        }
        prevColorTag = colorTag

        for tag in 201...206 {
            let button = self.view.viewWithTag(tag) as? UIButton
            let noSexImage = UIImage(named: getNoSexCarIconName(colorTag, icon: tag))
            let image = UIImage(named: getCarIconName(Mine.sharedInstance.sex, color: colorTag, icon: tag))
            button?.setImage(noSexImage, for: UIControlState())
            button?.setImage(image, for: UIControlState.highlighted)
            button?.setImage(image, for: [UIControlState.selected, UIControlState.highlighted])
            button?.setImage(image, for: UIControlState.selected)
        }

        let iconButton = self.view.viewWithTag(iconTag) as? UIButton
        iconButton?.isSelected = true

        if prevIconTag != -1 && prevIconTag != iconTag {
            let prevButton = self.view.viewWithTag(prevIconTag) as? UIButton
            prevButton?.isSelected = false
        }
        prevIconTag = iconTag
    }

    @IBAction func onColorAction(_ sender: UIButton) {
        colorTag = sender.tag
        loadCurrentIcon()
    }

    @IBAction func onIconAction(_ sender: UIButton) {
        iconTag = sender.tag
        loadCurrentIcon()
    }

    @IBAction func onSaveAction(_ sender: UIButton) {
        Mine.sharedInstance.carHeadBg = colorTag
        Mine.sharedInstance.carHeadId = iconTag
        User.updateInfo(color: String(colorTag), icon: String(iconTag)).subscribeNext { res in
            if let user = res.data {
                Mine.sharedInstance.updateLogin(user)
            }
        }.addDisposableTo(disposeBag)
        _ = self.navigationController?.popViewController(animated: true)
    }

}
