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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let colorTag = Mine.sharedInstance.carHeadBg
        let iconTag = Mine.sharedInstance.carHeadId
        values[1] = getCarIconName(Mine.sharedInstance.sex, color: colorTag, icon: iconTag)
        values[2] = Mine.sharedInstance.nickname ?? "用户名"
        values[3/*5*/] = getSexString(Mine.sharedInstance.sex)
        values[4/*6*/] = DeviceDataService.sharedInstance.rxDistrict.value
        self.tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 3
        case 1:
            return 2
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: PersonInfoCell?
        if (indexPath as NSIndexPath).section == 0 && ((indexPath as NSIndexPath).row == 0 || (indexPath as NSIndexPath).row == 1 /*|| indexPath.row == 3*/) {
            cell = tableView.dequeueReusableCell(with: R.reuseIdentifier.info_icon, for:indexPath)
            cell?.title.text = titles[(indexPath as NSIndexPath).row]
            if (indexPath as NSIndexPath).row == 0 {
                Mine.sharedInstance.setAvatarImage(cell!.icon)
            } else {
                cell?.icon.image = UIImage(named: values[(indexPath as NSIndexPath).row])
            }
        } else {
            cell = tableView.dequeueReusableCell(with: R.reuseIdentifier.info_text, for:indexPath)
            cell?.selectionStyle = .default
            cell?.accessoryType = .disclosureIndicator
            if (indexPath as NSIndexPath).section == 0 {
                cell?.title.text = titles[(indexPath as NSIndexPath).row]
                cell?.value.text = values[(indexPath as NSIndexPath).row]
            } else {
                cell?.title.text = titles[(indexPath as NSIndexPath).row + 3/*5*/]
                cell?.value.text = values[(indexPath as NSIndexPath).row + 3/*5*/]
                if (indexPath as NSIndexPath).row == 1 {
                    cell?.selectionStyle = .none
                    cell?.accessoryType = .none
                }
            }
        }

        return cell!
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).section == 0 && ((indexPath as NSIndexPath).row == 0 || (indexPath as NSIndexPath).row == 1) {
            return 80
        } else {
            return 60
        }
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableView.sectionHeaderHeight
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if (indexPath as NSIndexPath).section == 0 {
            switch (indexPath as NSIndexPath).row {
            case 0:
                showImagePickerAlertView()
                tableView.deselectRow(at: indexPath, animated: true)
            case 1:
                let controller = R.storyboard.mine.car_icon
                showViewController(controller!)
            case 2:
                let vc = InfoEditViewController(mode: .Nickname)
                showViewController(vc)
            default:
                break
            }
        } else if (indexPath as NSIndexPath).section == 1 {
            switch (indexPath as NSIndexPath).row {
            case 0:
                showViewController(InfoEditViewController(mode: .Sex))
            default:
                break
            }
        }
    }

    func showImagePickerAlertView() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        alertController.addAction(UIAlertAction(title: "拍照", style: UIAlertActionStyle.default, handler: {(action) in
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            self.present(imagePicker, animated: true, completion: nil)
        }))
        alertController.addAction(UIAlertAction(title: "从手机相册选择", style: UIAlertActionStyle.default, handler: {(action) in
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }))
        alertController.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.cancel, handler: nil))
        if let popoverController = alertController.popoverPresentationController {
            let sourceView = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0))
            popoverController.sourceView = sourceView
            popoverController.sourceRect = sourceView!.bounds
        }
        present(alertController, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let avatarImage = image.scaleImage(size: CGSize(width: 254, height: 254))
            User.uploadHeader(avatarImage).subscribeNext { gkResult in
                if let user = gkResult.data {
                    Mine.sharedInstance.updateLogin(user)
                    self.tableView.reloadData()
                }
                }.addDisposableTo(disposeBag)
            dismiss(animated: true, completion: {_ in
                self.tableView.reloadData()
            })
        }
    }

}
