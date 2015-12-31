//
//  CarListViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/12/23.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import UIKit

class CarListViewController: UIViewController {

    @IBOutlet weak var addButton1: UIButton!
    @IBOutlet weak var addButton2: UIButton!
    @IBOutlet weak var addButton3: UIButton!

    @IBOutlet weak var carInfoView1: CarInfoView!
    @IBOutlet weak var carInfoView2: CarInfoView!
    @IBOutlet weak var carInfoView3: CarInfoView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(animated: Bool) {
        if gRealm?.objects(CarInfo).count == 0 {
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
        if let car1 = gRealm?.objects(CarInfo).filter("id = 0").first {
            carInfoView1.updateLogo(car1.imageUrl)
            carInfoView1.didButtonTapped = showDetailView(0)
            carInfoView1.updateText(car1.model, year: car1.year, detail: car1.detail, license: car1.lisence)
            carInfoView1.hidden = false
        }

        if let car2 = gRealm?.objects(CarInfo).filter("id = 1").first {
            carInfoView2.updateLogo(car2.imageUrl)
            carInfoView2.didButtonTapped = showDetailView(1)
            carInfoView2.updateText(car2.model, year: car2.year, detail: car2.detail, license: car2.lisence)
            carInfoView2.hidden = false
        }

        if let car3 = gRealm?.objects(CarInfo).filter("id = 2").first {
            carInfoView3.updateLogo(car3.imageUrl)
            carInfoView3.didButtonTapped = showDetailView(2)
            carInfoView3.updateText(car3.model, year: car3.year, detail: car3.detail, license: car3.lisence)
            carInfoView3.hidden = false
        }
    }

    func showDetailView(id: Int)() {
        let vc = R.storyboard.mine.car_detail
        vc?.id = id
        self.showViewController(vc!)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
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
