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

    var categeries: [String] = []
    var brands: [String: [String]] = [:]
    var models: [String: [String]] = [:]

    init() {
    }

    mutating func fetchCarInfos() -> Observable<Void> {
        return CarInfo.info().observeOn(operationScheduler).map { result in
            guard let carInfos = result.dataArray else {
                return
            }
            for carInfo in carInfos {
                let categery = carInfo.category
                let brand = carInfo.brand
                let model = carInfo.model
                //let modelId = carInfo.modelId

                if self.brands[categery] == nil {
                    self.brands[categery] = []
                }
                if self.models[brand] == nil {
                    self.models[brand] = []
                }

                if !self.categeries.contains(categery) {
                    self.categeries.append(categery)
                }
                if !self.brands[categery]!.contains(brand) {
                    self.brands[categery]!.append(brand)
                }
                self.models[brand]!.append(model)
            }
            }.observeOn(MainScheduler.sharedInstance)
    }
}
