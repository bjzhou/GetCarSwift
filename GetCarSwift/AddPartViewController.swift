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
    let carPart = CarPart()

    override func viewDidLoad() {
        super.viewDidLoad()

        imagePicker.delegate = self

        addEndEditingGesture(self.view)

        _ = cameraButton.rx_tap.takeUntil(self.rx_deallocated).subscribeNext {
            self.showImagePickerAlertView()
        }
    }

    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)

        cameraButton.setImage(R.image.camera, forState: .Normal)
        KingfisherManager.sharedManager.cache.retrieveImageForKey(carPart.imageKey, options: KingfisherManager.OptionsNone) { image, _ in
            if let image = image {
                self.cameraButton.setImage(image, forState: .Normal)
            }
        }
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
        carPart.title = titleTextField.text!
        carPart.detail = detailTextView.text!
        gRealm?.writeOptional {
            gRealm?.objects(CarInfo).filter("id = \(self.id)").first?.parts.append(self.carPart)
        }
        self.navigationController?.popViewControllerAnimated(true)
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
        KingfisherManager.sharedManager.cache.storeImage(image.scaleImage(size: CGSize(width: 300, height: 200)), forKey: carPart.imageKey)
        dismissViewControllerAnimated(true, completion: nil)
    }

    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
    }

}
