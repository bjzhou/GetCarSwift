//
//  BgChoiceViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/5/16.
//  Copyright (c) 2015年 周斌佳. All rights reserved.
//

import UIKit
import Haneke

class BgChoiceViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var collection: UICollectionView!

    let imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collection.delegate = self
        collection.dataSource = self
        imagePicker.delegate = self
    }

    @IBAction func onCameraAction(sender: UIButton) {
        imagePicker.sourceType = .Camera
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    @IBAction func onGalleryAction(sender: UIButton) {
        imagePicker.sourceType = .PhotoLibrary
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(R.reuseIdentifier.bg_small.identifier, forIndexPath: indexPath) as UICollectionViewCell
        let imageView = cell.viewWithTag(401) as! UIImageView
        imageView.image = UIImage(named: getSmallHomepageBg(indexPath.row + 1))
        cell.addSubview(imageView)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let userDefaults = NSUserDefaults.standardUserDefaults();
        userDefaults.setInteger(indexPath.row + 1, forKey: "homepage_bg")
        navigationController?.popViewControllerAnimated(true)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        Shared.imageCache.set(value: image, key: "homepage_bg")
        let userDefaults = NSUserDefaults.standardUserDefaults();
        userDefaults.setInteger(1000, forKey: "homepage_bg")
        dismissViewControllerAnimated(true, completion: nil)
        navigationController?.popViewControllerAnimated(true)
    }

    
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
    }
}
