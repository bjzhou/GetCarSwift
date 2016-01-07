//
//  AddPartViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/12/23.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import UIKit
import Kingfisher

class AddPartViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var detailTextView: KMPlaceholderTextView!

    var id = 0

    let imagePicker = UIImagePickerController()
    var carPart = CarPart()

    override func viewDidLoad() {
        super.viewDidLoad()

        imagePicker.delegate = self

        addEndEditingGesture(self.view)

        _ = cameraButton.rx_tap.takeUntil(self.rx_deallocated).subscribeNext {
            self.showImagePickerAlertView()
        }

        titleTextField.text = carPart.title
        detailTextView.text = carPart.detail
        if !carPart.imageUrl.trim().isEmpty {
            cameraButton.kf_setImageWithURL(NSURL(string: carPart.imageUrl)!, forState: .Normal, placeholderImage: R.image.camera)
        }
    }

    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
    }

    func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo, keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue else {
            return
        }

        if detailTextView.isFirstResponder() {
            UIView.animateWithDuration(0.3, animations: {
                self.view.frame.origin = CGPoint(x: 0, y: 64-keyboardSize.height)
            })
        }
    }

    func keyboardWillHide(notification: NSNotification) {
        UIView.animateWithDuration(0.3, animations: {
            self.view.frame.origin = CGPoint(x: 0, y: 64)
        })
    }

    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    @IBAction func didSaveAction(sender: AnyObject) {
        if self.titleTextField.text?.trim() == "" || self.cameraButton.imageForState(.Normal) == R.image.camera {
            Toast.makeToast(message: "请完善配件信息")
            return
        }

        Toast.makeToastActivity()
        async {
            let image = self.cameraButton.imageForState(.Normal)?.scaleImage(size: CGSize(width: 600, height: 400))
            main {
                if let carInfo = gRealm?.objects(CarInfo).filter("id = \(self.id)").first, image = image {
                    gRealm?.writeOptional {
                        self.carPart.title = self.titleTextField.text!
                        self.carPart.detail = self.detailTextView.text!
                    }
                    if let _ = self.carPart.realm {
                        _ = CarInfo.updateUserCarPart(self.carPart.id, userCarId: carInfo.carUserId, name: self.carPart.title, desc: self.carPart.detail, img: image).subscribeNext { res in
                            Toast.hideToastActivity()
                            self.navigationController?.popViewControllerAnimated(true)
                        }
                    } else {
                        gRealm?.writeOptional {
                            carInfo.parts.append(self.carPart)
                        }

                        _ = CarInfo.addUserCarPart(carInfo.carUserId, name: self.carPart.title, desc: self.carPart.detail, img: image).subscribeNext { res in
                            if let json = res.data {
                                gRealm?.writeOptional {
                                    self.carPart.id = json["user_car_part_id"].intValue
                                }
                            }
                            Toast.hideToastActivity()
                            self.navigationController?.popViewControllerAnimated(true)
                        }
                    }
                }
            }
        }
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
            popoverController.sourceView = cameraButton
            popoverController.sourceRect = cameraButton.bounds
        }
        presentViewController(alertController, animated: true, completion: nil)
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String: AnyObject]?) {
        self.cameraButton.setImage(image, forState: .Normal)
        dismissViewControllerAnimated(true, completion: nil)
    }

}
