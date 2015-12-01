//
//  PersonInfoViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/4/11.
//  Copyright (c) 2015年 周斌佳. All rights reserved.
//

import UIKit
import RxSwift

class PersonInfoViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let disposeBag = DisposeBag()

    let titles = ["头像", "车形象", "用户名", /*"我的二维码", "我的地址",*/ "性别", "地区"/*, "个性签名"*/]
    var values = ["avatar", getCarIconName(0, color: 0, icon: 0), "SURA"/*, IMAGE_QRCODE, ""*/, "女", "上海浦东新区"/*, ""*/]

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(animated: Bool) {
        let colorTag = Mine.sharedInstance.carHeadBg
        let iconTag = Mine.sharedInstance.carHeadId
        values[1] = getCarIconName(Mine.sharedInstance.sex, color: colorTag, icon: iconTag)
        values[2] = Mine.sharedInstance.nickname ?? "用户名"
        values[3/*5*/] = getSexString(Mine.sharedInstance.sex)
        values[4/*6*/] = DeviceDataService.sharedInstance.rxDistrict.value
        self.tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 3
        case 1:
            return 2
        default:
            return 0
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: PersonInfoCell
        if indexPath.section == 0 && (indexPath.row == 0 || indexPath.row == 1 /*|| indexPath.row == 3*/) {
            cell = tableView.dequeueReusableCellWithIdentifier("info_icon", forIndexPath:indexPath) as! PersonInfoCell
            cell.title.text = titles[indexPath.row]
            if indexPath.row == 0 {
                Mine.sharedInstance.setAvatarImage(cell.icon)
            } else {
                cell.icon.image = UIImage(named: values[indexPath.row])
            }
        } else {
            cell = tableView.dequeueReusableCellWithIdentifier("info_text", forIndexPath:indexPath) as! PersonInfoCell
            if indexPath.section == 0 {
                cell.title.text = titles[indexPath.row]
                cell.value.text = values[indexPath.row]
            } else {
                cell.title.text = titles[indexPath.row + 3/*5*/]
                cell.value.text = values[indexPath.row + 3/*5*/]
            }
        }

        return cell
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 && (indexPath.row == 0 || indexPath.row == 1) {
            return 80
        } else {
            return 60
        }
    }

    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableView.sectionHeaderHeight
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                showImagePickerAlertView()
            case 1:
                let controller = R.storyboard.mine.car_icon
                self.navigationController?.showViewController(controller!, sender: self)
            case 2:
                let vc = InfoEditViewController(mode: .Nickname)
                self.navigationController?.showViewController(vc, sender: self)
            default:
                break
            }
        } else if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                self.navigationController?.showViewController(InfoEditViewController(mode: .Sex), sender: self)
            default:
                break
            }
        }
    }

    func showImagePickerAlertView() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        alertController.addAction(UIAlertAction(title: "拍照", style: UIAlertActionStyle.Default, handler: {(action) in
            imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }))
        alertController.addAction(UIAlertAction(title: "从手机相册选择", style: UIAlertActionStyle.Default, handler: {(action) in
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }))
        alertController.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
        if let popoverController = alertController.popoverPresentationController {
            let sourceView = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))
            popoverController.sourceView = sourceView
            popoverController.sourceRect = sourceView!.bounds
        }
        presentViewController(alertController, animated: true, completion: nil)
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        let avatarImage = image.scaleImage(size: CGSizeMake(254, 254))
        User.uploadHeader(avatarImage).subscribeNext { gkResult in
            if let user = gkResult.data {
                Mine.sharedInstance.updateLogin(user)
                self.tableView.reloadData()
            }
            }.addDisposableTo(disposeBag)
        dismissViewControllerAnimated(true, completion: {_ in
            self.tableView.reloadData()
        })
    }

    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    }
    */

}
