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
        if gRealm?.allObjects(ofType: CarInfo.self).count == 0 {
            _ = CarInfo.getUserCar().subscribeNext { res in
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
            }
        }
        updateCars()
    }

    func updateCars() {
        if let car1 = gRealm?.allObjects(ofType: CarInfo.self).filter(using: "id = 0").first {
            buttonImageView1.kf_setImageWithURL(URL(string: car1.imageUrl)!, placeholderImage: defaultImage)
            carLabel1.text = car1.model + " " + car1.detail
        }

        if let car2 = gRealm?.allObjects(ofType: CarInfo.self).filter(using: "id = 1").first {
            buttonImageView2.kf_setImageWithURL(URL(string: car2.imageUrl)!, placeholderImage: defaultImage)
            carLabel2.text = car2.model + " " + car2.detail
        }

        if let car3 = gRealm?.allObjects(ofType: CarInfo.self).filter(using: "id = 2").first {
            buttonImageView3.kf_setImageWithURL(URL(string: car3.imageUrl)!, placeholderImage: defaultImage)
            carLabel3.text = car3.model + " " + car3.detail
        }
    }

    func showDetailView(_ id: Int) {
        let vc = R.storyboard.mine.car_detail
        vc?.id = id
        self.showViewController(vc!)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? CarDetailViewController {
            switch segue.identifier {
            case R.segue.add_car0?:
                vc.id = 0
            case R.segue.add_car1?:
                vc.id = 1
            case R.segue.add_car2?:
                vc.id = 2
            default:
                break
            }
        }
    }

}
