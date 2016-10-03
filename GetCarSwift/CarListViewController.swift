//
//  CarListViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/12/23.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import UIKit

class CarListViewController: UIViewController {

    let defaultImage = UIImage().scaleImage(size: CGSize(width: 65, height: 65))

    @IBOutlet weak var addButton1: UIButton!
    @IBOutlet weak var addButton2: UIButton!
    @IBOutlet weak var addButton3: UIButton!

    @IBOutlet weak var carLabel1: UILabel!
    @IBOutlet weak var carLabel2: UILabel!
    @IBOutlet weak var carLabel3: UILabel!

    @IBOutlet weak var buttonImageView1: UIImageView!
    @IBOutlet weak var buttonImageView2: UIImageView!
    @IBOutlet weak var buttonImageView3: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        if gRealm?.objects(CarInfo.self).count == 0 {
            _ = CarInfo.getUserCar().subscribe(onNext: { res in
                guard let cars = res.dataArray else {
                    return
                }

                for i in 0..<cars.count {
                    cars[i].id = i
                }
                gRealm?.writeOptional {
                    gRealm?.add(cars)
                }
                self.updateCars()
            })
        }
        updateCars()
    }

    func updateCars() {
        if let car1 = gRealm?.objects(CarInfo.self).filter("id = 0").first {
            buttonImageView1.kf.setImage(with: URL(string: car1.imageUrl)!, placeholder: defaultImage)
            carLabel1.text = car1.model + " " + car1.detail
        }

        if let car2 = gRealm?.objects(CarInfo.self).filter("id = 1").first {
            buttonImageView2.kf.setImage(with: URL(string: car2.imageUrl)!, placeholder: defaultImage)
            carLabel2.text = car2.model + " " + car2.detail
        }

        if let car3 = gRealm?.objects(CarInfo.self).filter("id = 2").first {
            buttonImageView3.kf.setImage(with: URL(string: car3.imageUrl)!, placeholder: defaultImage)
            carLabel3.text = car3.model + " " + car3.detail
        }
    }

    func showDetailView(_ id: Int) {
        let vc = R.storyboard.mine.car_detail()
        vc?.id = id
        self.showViewController(vc!)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? CarDetailViewController {
            switch segue.identifier {
            case R.segue.carListViewController.add_car0.identifier?:
                vc.id = 0
            case R.segue.carListViewController.add_car1.identifier?:
                vc.id = 1
            case R.segue.carListViewController.add_car2.identifier?:
                vc.id = 2
            default:
                break
            }
        }
    }

}
