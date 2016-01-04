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

    override func viewDidLoad() {
        super.viewDidLoad()

        if let carInfo = gRealm?.objects(CarInfo).filter("id = \(id)").first {
            modelLabel.text = carInfo.model
            lisenceTextField.text = carInfo.lisence
            nameTextField.text = carInfo.name
            yearTextField.text = carInfo.year
            versionTextField.text = carInfo.detail

            self.carInfo = carInfo
        } else {
            carInfo = CarInfo(value: ["id": id])
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            let carChoose = R.storyboard.login.car_choose
            carChoose?.carDelegate = self
            showViewController(carChoose!)
        }
    }

    func didCarSelected(car: CarInfo) {
        gRealm?.writeOptional {
            self.carInfo.model = car.model
            self.carInfo.modelId = car.modelId
        }
        modelLabel.text = car.model
    }

    @IBAction func didSaveAction(sender: AnyObject) {
        if modelLabel.text == "" {
            Toast.makeToast(message: "请选择车辆品牌")
            return
        }
        gRealm?.writeOptional {
            self.carInfo.model = self.modelLabel.text!
            self.carInfo.lisence = self.lisenceTextField.text!
            self.carInfo.name = self.nameTextField.text!
            self.carInfo.year = self.yearTextField.text!
            self.carInfo.detail = self.versionTextField.text!
            gRealm?.add(self.carInfo, update: true)
        }
        if let _ = carInfo.realm {
            _ = CarInfo.updateUserCar(carInfo.carUserId, carId: self.carInfo.modelId, number: self.carInfo.lisence, username: self.carInfo.name, year: self.carInfo.year, version: self.carInfo.detail).subscribeNext { res in
                self.navigationController?.popViewControllerAnimated(true)
            }
        } else {
            _ = CarInfo.addUserCar(self.carInfo.modelId, number: self.carInfo.lisence, username: self.carInfo.name, year: self.carInfo.year, version: self.carInfo.detail).subscribeNext { res in
                if let json = res.data {
                    gRealm?.writeOptional {
                        self.carInfo.carUserId = json["user_car_id"].intValue
                    }
                }
                self.navigationController?.popViewControllerAnimated(true)
            }
        }
    }

}
