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
        myAvatar.layer.borderColor = UIColor.white.cgColor
        myAvatar.layer.borderWidth = 2

        let tapRecgnizer = UITapGestureRecognizer()
        tapRecgnizer.numberOfTapsRequired = 1
        tapRecgnizer.rx.event.subscribe(onNext: { (gr) -> Void in
            self.showViewController(R.storyboard.mine.bg_choice()!)
            }).addDisposableTo(disposeBag)
        homepageBg.addGestureRecognizer(tapRecgnizer)

        let tapRecgnizer2 = UITapGestureRecognizer()
        tapRecgnizer2.numberOfTapsRequired = 1
        tapRecgnizer2.rx.event.subscribe(onNext: { (gr) -> Void in
            self.showImagePickerAlertView()
            }).addDisposableTo(disposeBag)
        myAvatar.addGestureRecognizer(tapRecgnizer2)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        Mine.sharedInstance.setAvatarImage(myAvatar)
        sexImage.image = Mine.sharedInstance.sex == 0 ? R.image.mine_female() : R.image.mine_male()
        nickname.text = Mine.sharedInstance.nickname
        DeviceDataService.sharedInstance.rxDistrict.asObservable().subscribe(onNext: {str in
            self.position.text = str
        }).addDisposableTo(disposeBag)

        let userDefaults = UserDefaults.standard
        let index = userDefaults.integer(forKey: "homepage_bg")
        if index == 1000 {
            KingfisherManager.shared.cache.retrieveImage(forKey: "homepage_bg", options: []) { image, _ in
                self.homepageBg.image = image
            }
        } else {
            homepageBg.image = UIImage(named: getHomepageBg(index == 0 ? 1 : index))
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableView.sectionHeaderHeight
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath) as UITableViewCell
        return cell
    }

    func showImagePickerAlertView() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "拍照", style: .default, handler: {(action) in
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            self.present(imagePicker, animated: true, completion: nil)
        }))
        alertController.addAction(UIAlertAction(title: "从手机相册选择", style: .default, handler: {(action) in
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }))
        alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = myAvatar
            popoverController.sourceRect = myAvatar.bounds
        }
        present(alertController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let avatarImage = image.scaleImage(size: CGSize(width: 254, height: 254))
            User.uploadHeader(avatarImage).subscribe(onNext: { gkResult in
                if let user = gkResult.data {
                    Mine.sharedInstance.updateLogin(user)
                    Mine.sharedInstance.setAvatarImage(self.myAvatar)
                }
                }).addDisposableTo(disposeBag)
            dismiss(animated: true, completion: {_ in
                Mine.sharedInstance.setAvatarImage(self.myAvatar)
            })
        }
    }
}
