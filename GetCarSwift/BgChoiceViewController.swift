//
//  BgChoiceViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/5/16.
//  Copyright (c) 2015年 &#21608;&#25996;&#20339;. All rights reserved.
//

import UIKit

class BgChoiceViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var collection: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collection.delegate = self
        collection.dataSource = self

    }

    @IBAction func onCameraAction(sender: UIButton) {
        var imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .Camera
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    @IBAction func onGalleryAction(sender: UIButton) {
        var imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .PhotoLibrary
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("bg_small", forIndexPath: indexPath) as! UICollectionViewCell
        var imageView = cell.viewWithTag(401) as! UIImageView
        imageView.image = UIImage(named: getSmallHomepageBg(indexPath.row + 1))
        cell.addSubview(imageView)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        var userDefaults = NSUserDefaults.standardUserDefaults();
        userDefaults.setInteger(indexPath.row + 1, forKey: "homepage_bg")
        navigationController?.popViewControllerAnimated(true)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        saveImage(image, "homepage_bg")
        var userDefaults = NSUserDefaults.standardUserDefaults();
        userDefaults.setInteger(1000, forKey: "homepage_bg")
        dismissViewControllerAnimated(true, completion: nil)
        navigationController?.popViewControllerAnimated(true)
    }
    
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
    }
}
