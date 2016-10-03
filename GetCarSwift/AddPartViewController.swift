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
    @IBOutlet weak var cameraButtonImageView: UIImageView!
    @IBOutlet weak var detailTextView: KMPlaceholderTextView!

    var id = 0

    let imagePicker = UIImagePickerController()
    var carPart = CarPart()
    var isNewPart = true

    override func viewDidLoad() {
        super.viewDidLoad()

        imagePicker.delegate = self

        addEndEditingGesture(self.view)

        _ = cameraButton.rx.tap.takeUntil(self.rx.deallocated).subscribe(onNext: {
            self.showImagePickerAlertView()
        })

        titleTextField.text = carPart.title
        detailTextView.text = carPart.detail
        if !carPart.imageUrl.trim().isEmpty {
            cameraButtonImageView.kf.setImage(with: URL(string: carPart.imageUrl)!, placeholder: R.image.camera())
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(AddPartViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AddPartViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = (notification as NSNotification).userInfo, let keyboardSize = (userInfo[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue else {
            return
        }

        if detailTextView.isFirstResponder {
            UIView.animate(withDuration: 0.3, animations: {
                self.view.frame.origin = CGPoint(x: 0, y: 64-keyboardSize.height)
            })
        }
    }

    func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.3, animations: {
            self.view.frame.origin = CGPoint(x: 0, y: 64)
        })
    }

    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }

    @IBAction func didSaveAction(_ sender: AnyObject) {
        if self.titleTextField.text?.trim() == "" || self.cameraButton.image(for: UIControlState()) == R.image.camera() {
            Toast.makeToast(message: "请完善配件信息")
            return
        }

        Toast.makeToastActivity()
        async {
            let image = self.cameraButtonImageView.image?.scaleImage(scale: 0.3)
            main {
                if let carInfo = gRealm?.objects(CarInfo.self).filter("id = \(self.id)").first, let image = image {
                    gRealm?.writeOptional {
                        self.carPart.title = self.titleTextField.text!
                        self.carPart.detail = self.detailTextView.text!
                    }
                    if self.isNewPart {
                        _ = CarInfo.addUserCarPart(carInfo.carUserId, name: self.carPart.title, desc: self.carPart.detail, img: image).subscribe(onNext: { res in
                            if let json = res.data {
                                gRealm?.writeOptional {
                                    self.carPart.id = json["user_car_part_id"].intValue
                                }
                            }
                            Toast.hideToastActivity()
                            _ = self.navigationController?.popViewController(animated: true)
                        })
                    } else {
                        _ = CarInfo.updateUserCarPart(self.carPart.id, userCarId: carInfo.carUserId, name: self.carPart.title, desc: self.carPart.detail, img: image).subscribe(onNext: { res in
                            Toast.hideToastActivity()
                            _ = self.navigationController?.popViewController(animated: true)
                        })
                    }
                }
            }
        }
    }

    func showImagePickerAlertView() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
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
            popoverController.sourceView = cameraButton
            popoverController.sourceRect = cameraButton.bounds
        }
        present(alertController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.cameraButtonImageView.contentMode = .scaleAspectFill
            self.cameraButtonImageView.image = image
            self.cameraButtonImageView.clipsToBounds = true
            dismiss(animated: true, completion: nil)
        }
    }

}
