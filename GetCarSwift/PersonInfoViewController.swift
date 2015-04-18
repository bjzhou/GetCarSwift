//
//  PersonInfoViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/4/11.
//  Copyright (c) 2015年 周斌佳. All rights reserved.
//

import UIKit

class PersonInfoViewController: UITableViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    let titles = ["头像", "车形象", "用户名", "我的二维码", "我的地址", "性别", "地区", "个性签名"]
    var values = [IMAGE_AVATAR, getCarIconName(0, 0, 0), "SURA", IMAGE_QRCODE, "", "女", "上海浦东新区", ""]
    
    var avatarImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        avatarImage = UIImage(contentsOfFile: getFilePath("avatar"))
    }
    
    override func viewWillAppear(animated: Bool) {
        let sex = NSUserDefaults.standardUserDefaults().integerForKey("sex")
        let colorTag = NSUserDefaults.standardUserDefaults().integerForKey("color")
        let iconTag = NSUserDefaults.standardUserDefaults().integerForKey("icon")
        values[1] = getCarIconName(sex, colorTag, iconTag)
        values[5] = getSexString(sex)
        self.tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 5
        } else {
            return 3
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: PersonInfoCell
        if indexPath.section == 0 && (indexPath.row == 0 || indexPath.row == 1 || indexPath.row == 3) {
            cell = tableView.dequeueReusableCellWithIdentifier("info_icon", forIndexPath:indexPath) as! PersonInfoCell
            cell.title.text = titles[indexPath.row]
            cell.icon.image = UIImage(named: values[indexPath.row])
            if indexPath.row == 0 && avatarImage != nil {
                cell.icon.image = avatarImage
            }
        } else {
            cell = tableView.dequeueReusableCellWithIdentifier("info_text", forIndexPath:indexPath) as! PersonInfoCell
            if indexPath.section == 0 {
                cell.title.text = titles[indexPath.row]
                cell.value.text = values[indexPath.row]
            } else {
                cell.title.text = titles[indexPath.row + 5]
                cell.value.text = values[indexPath.row + 5]
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
        return tableView.sectionHeaderHeight;
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                showImagePickerAlertView()
            case 1:
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let controller = storyboard.instantiateViewControllerWithIdentifier("car_icon") as! UIViewController
                self.navigationController?.showViewController(controller, sender: self)
            default:
                break
            }
        } else {
            switch indexPath.row {
            case 0:
                self.navigationController?.showViewController(InfoEditViewController(), sender: self)
            default:
                break;
            }
        }
        
    }
    
    func showImagePickerAlertView() {
        var imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        var alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        alertController.addAction(UIAlertAction(title: "拍照", style: UIAlertActionStyle.Default, handler: {(action) in
            imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
            self.presentViewController(imagePicker, animated: true, completion: {() in
            
            })
        }))
        alertController.addAction(UIAlertAction(title: "从手机相册选择", style: UIAlertActionStyle.Default, handler: {(action) in
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            self.presentViewController(imagePicker, animated: true, completion: {() in
                
            })
            
        }))
        alertController.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        avatarImage = scaleImage(image, CGSizeMake(254, 254))
        saveImage(avatarImage!, "avatar")
        self.tableView.reloadData()
        dismissViewControllerAnimated(true, completion: nil)
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
