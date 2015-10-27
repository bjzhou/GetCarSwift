//
//  CarTableViewModel.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/9/26.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

// for old data
//                self.categeries = json.sortedDictionaryKeys() ?? []
//                for categery in self.categeries {
//                    self.brands[categery] = json[categery].sortedDictionaryKeys() ?? []
//                    for brand in self.brands[categery]! {
//                        self.models[brand] = json[categery, brand].arrayObject as? [String]
//                    }
//                }

struct CarTableViewModel {

    let disposeBag = DisposeBag()

    init() {
    }

    func fetchCarInfos(reloadData: ([String], [String: [String]], [String: [String]]) -> ()) {
        CarInfo.info().observeOn(operationScheduler).map { result in
            var categeries: [String] = []
            var brands: [String: [String]] = [:]
            var models: [String: [String]] = [:]
            guard let carInfos = result.dataArray else {
                return (categeries, brands, models)
            }
            for carInfo in carInfos {
                let categery = carInfo.category
                let brand = carInfo.brand
                let model = carInfo.model
                //let modelId = carInfo.modelId

                if brands[categery] == nil {
                    brands[categery] = []
                }
                if models[brand] == nil {
                    models[brand] = []
                }

                if !categeries.contains(categery) {
                    categeries.append(categery)
                }
                if !brands[categery]!.contains(brand) {
                    brands[categery]!.append(brand)
                }
                models[brand]!.append(model)
            }
            return (categeries, brands, models)
            }.observeOn(MainScheduler.sharedInstance)
            .subscribeNext { (c: [String], b: [String: [String]], m: [String: [String]]) in
                reloadData(c, b, m)
        }.addDisposableTo(disposeBag)
    }
}
