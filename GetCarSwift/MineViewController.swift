//
//  MineViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/4/11.
//  Copyright (c) 2015年 周斌佳. All rights reserved.
//

import UIKit
import Kingfisher
import RxSwift

class MineViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var position: UILabel!
    @IBOutlet weak var nickname: UILabel!
    @IBOutlet weak var sexImage: UIImageView!
    @IBOutlet weak var myAvatar: UIImageView!
    @IBOutlet weak var homepageBg: UIImageView!

    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        myAvatar.layer.masksToBounds = true
        myAvatar.layer.cornerRadius = 10
        myAvatar.layer.borderColor = UIColor.whiteColor().CGColor
        myAvatar.layer.borderWidth = 2
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "didTapHomepageBg")
        tapRecognizer.numberOfTapsRequired = 1
        homepageBg.addGestureRecognizer(tapRecognizer)

        let tapRecognizer2 = UITapGestureRecognizer(target: self, action: "didTapAvatar")
        tapRecognizer2.numberOfTapsRequired = 1
        myAvatar.addGestureRecognizer(tapRecognizer2)
    }

    func didTapHomepageBg() {
        showViewController(R.storyboard.mine.bg_choice!)
    }

    func didTapAvatar() {
        showImagePickerAlertView()
    }

    override func viewWillAppear(animated: Bool) {
        Mine.sharedInstance.setAvatarImage(myAvatar)
        sexImage.image = Mine.sharedInstance.sex == 0 ? R.image.mine_female : R.image.mine_male
        nickname.text = Mine.sharedInstance.nickname
        DeviceDataService.sharedInstance.rxDistrict.bindTo(position.rx_text).addDisposableTo(disposeBag)

        let userDefaults = NSUserDefaults.standardUserDefaults()
        let index = userDefaults.integerForKey("homepage_bg")
        if index == 1000 {
            KingfisherManager.sharedManager.cache.retrieveImageForKey("homepage_bg", options: KingfisherManager.OptionsNone) { image, _ in
                self.homepageBg.image = image
            }
        } else {
            homepageBg.image = UIImage(named: getHomepageBg(index == 0 ? 1 : index))
        }
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableView.sectionHeaderHeight
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath) as UITableViewCell
        return cell
    }

    func showImagePickerAlertView() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alertController.addAction(UIAlertAction(title: "拍照", style: .Default, handler: {(action) in
            imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }))
        alertController.addAction(UIAlertAction(title: "从手机相册选择", style: .Default, handler: {(action) in
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }))
        alertController.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: nil))
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = myAvatar
            popoverController.sourceRect = myAvatar.bounds
        }
        presentViewController(alertController, animated: true, completion: nil)
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        let avatarImage = image.scaleImage(size: CGSize(width: 254, height: 254))
        User.uploadHeader(avatarImage).subscribeNext { gkResult in
            if let user = gkResult.data {
                Mine.sharedInstance.updateLogin(user)
                Mine.sharedInstance.setAvatarImage(self.myAvatar)
            }
            }.addDisposableTo(disposeBag)
        dismissViewControllerAnimated(true, completion: {_ in
            Mine.sharedInstance.setAvatarImage(self.myAvatar)
        })
    }

    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
    }
}
