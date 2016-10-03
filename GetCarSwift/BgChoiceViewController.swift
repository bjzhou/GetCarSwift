//
//  BgChoiceViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/5/16.
//  Copyright (c) 2015年 周斌佳. All rights reserved.
//

import UIKit
import Kingfisher

class BgChoiceViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var collection: UICollectionView!

    let imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()

        collection.delegate = self
        collection.dataSource = self
        imagePicker.delegate = self

        if let flowLayout = collection.collectionViewLayout as? UICollectionViewFlowLayout {
            let cellWidth = (self.view.frame.width - 24) / 2
            let cellHeight = cellWidth * 116 / 175
            flowLayout.itemSize = CGSize(width: cellWidth, height: cellHeight)
        }
    }

    override func viewDidLayoutSubviews() {
    }

    @IBAction func onCameraAction(_ sender: UIButton) {
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    @IBAction func onGalleryAction(_ sender: UIButton) {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.bg_small, for: indexPath)
        cell?.bgImageView.image = UIImage(named: getSmallHomepageBg((indexPath as NSIndexPath).row + 1))
        return cell!
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let userDefaults = UserDefaults.standard
        userDefaults.set((indexPath as NSIndexPath).row + 1, forKey: "homepage_bg")
        _ = navigationController?.popViewController(animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            KingfisherManager.shared.cache.store(image, forKey: "homepage_bg")
            let userDefaults = UserDefaults.standard
            userDefaults.set(1000, forKey: "homepage_bg")
            dismiss(animated: true, completion: nil)
            _ = navigationController?.popViewController(animated: true)
        }
    }
}
