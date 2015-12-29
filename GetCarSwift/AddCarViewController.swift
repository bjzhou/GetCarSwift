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
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let newCar = CarInfo(value: ["id": id])
        carInfo = gRealm?.objects(CarInfo).filter("id = \(id)").first ?? newCar
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
            self.view.makeToast(message: "请选择车辆品牌")
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
        _ = User.updateInfo(carInfos: gRealm?.objects(CarInfo).map { $0 }).subscribeNext { res in
            self.navigationController?.popViewControllerAnimated(true)
        }
    }

}
