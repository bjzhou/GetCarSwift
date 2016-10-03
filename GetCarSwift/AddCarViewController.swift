//
//  AddCarViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/12/23.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import UIKit

class AddCarViewController: UITableViewController, CarTableNavigationDelegate {

    @IBOutlet weak var modelLabel: UILabel!
    @IBOutlet weak var lisenceTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var yearTextField: UITextField!
    @IBOutlet weak var versionTextField: UITextField!

    var id = 0
    var carInfo = CarInfo()
    var selectedModelId = 0
    var selectedImageUrl = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        if let carInfo = gRealm?.objects(CarInfo.self).filter("id = \(id)").first {
            modelLabel.text = carInfo.model
            lisenceTextField.text = carInfo.lisence
            nameTextField.text = carInfo.name
            yearTextField.text = carInfo.year
            versionTextField.text = carInfo.detail

            self.carInfo = carInfo
        } else {
            carInfo = CarInfo(value: ["id": id])
        }
        selectedModelId = carInfo.modelId
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).section == 0 && (indexPath as NSIndexPath).row == 0 {
            let carChoose = R.storyboard.login.car_choose()
            carChoose?.carDelegate = self
            showViewController(carChoose!)
        }
    }

    func didCarSelected(_ car: CarInfo) {
        selectedModelId = car.modelId
        modelLabel.text = car.model
        selectedImageUrl = car.imageUrl

    }

    @IBAction func didSaveAction(_ sender: AnyObject) {
        if modelLabel.text == "" {
            Toast.makeToast(message: "请选择车辆品牌")
            return
        }
        gRealm?.writeOptional {
            self.carInfo.model = self.modelLabel.text!
            self.carInfo.modelId = self.selectedModelId
            self.carInfo.imageUrl = self.selectedImageUrl
            self.carInfo.lisence = self.lisenceTextField.text!
            self.carInfo.name = self.nameTextField.text!
            self.carInfo.year = self.yearTextField.text!
            self.carInfo.detail = self.versionTextField.text!
        }
        if let _ = carInfo.realm {
            _ = CarInfo.updateUserCar(carInfo.carUserId, carId: self.carInfo.modelId, number: self.carInfo.lisence, username: self.carInfo.name, year: self.carInfo.year, version: self.carInfo.detail).subscribe(onNext: { res in
                _ = self.navigationController?.popViewController(animated: true)
            })
        } else {
            _ = CarInfo.addUserCar(self.carInfo.modelId, number: self.carInfo.lisence, username: self.carInfo.name, year: self.carInfo.year, version: self.carInfo.detail).subscribe(onNext: { res in
                if let json = res.data {
                    gRealm?.writeOptional {
                        self.carInfo.carUserId = json["user_car_id"].intValue
                    }
                }
                _ = self.navigationController?.popViewController(animated: true)
            })
            gRealm?.writeOptional {
                gRealm?.add(self.carInfo, update: true)
            }
        }
    }

}
