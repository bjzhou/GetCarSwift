//
//  CALayer+GK.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/12/9.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import Foundation

extension CALayer {
    func pauseAnimation() {
        let pausedTime = self.convertTime(CACurrentMediaTime(), fromLayer: nil)
        self.speed = 0
        self.timeOffset = pausedTime
    }

    func resumeAnimation() {
        let pausedTime = self.timeOffset
        self.speed = 1
        self.timeOffset = 0
        self.beginTime = 0
        let timeSincePause = self.convertTime(CACurrentMediaTime(), fromLayer: nil) - pausedTime
        self.beginTime = timeSincePause
    }
}