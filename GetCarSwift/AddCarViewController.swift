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

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            let carChoose = R.storyboard.login.car_choose
            carChoose?.carDelegate = self
            showViewController(carChoose!)
        }
    }

    func didCarSelected(car: String) {
        modelLabel.text = car
    }

    @IBAction func didSaveAction(sender: AnyObject) {
        if modelLabel.text == "" {
            self.view.makeToast(message: "请选择车辆品牌")
            return
        }
        let carInfo = CarInfo(value: ["id": id, "model": modelLabel.text!, "lisence": lisenceTextField.text!, "name": nameTextField.text!, "year": yearTextField.text!, "detail": versionTextField.text!])
        gRealm?.writeOptional {
            gRealm?.add(carInfo, update: true)
        }
        self.navigationController?.popViewControllerAnimated(true)
    }

}
