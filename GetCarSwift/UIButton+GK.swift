//
//  UIButton+UIButton.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/9/27.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

extension UIButton {

    public var rxSelected: AnyObserver<Bool> {
        return AnyObserver { [weak self] event in
            MainScheduler.ensureExecutingOnScheduler()

            switch event {
            case .Next(let value):
                self?.selected = value
            case .Error:
                break
            case .Completed:
                break
            }
        }
    }

}
