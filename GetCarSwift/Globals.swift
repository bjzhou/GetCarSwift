//
//  Globals.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/4/11.
//  Copyright (c) 2015年 周斌佳. All rights reserved.
//

import Foundation

let APP_VERSION = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String

let UI_COLOR_RED = UIColorFromRGB(0xcc0007)

let IMAGE_ARROW = "arrow"
let IMAGE_DABAOWEI = "gz_baowei"
let IMAGE_HOURAO = "gz_hourao"
let IMAGE_LUNGU = "gz_lunkuo"
let IMAGE_RED_CAR = "gz_keluzi_red"
let IMAGE_YELLOW_CAR = "gz_keluzi_yellow"
let IMAGE_BLUE_CAR = "gz_keluzi_blue"
let IMAGE_GRAY_CAR = "gz_keluzi_gray"
let IMAGE_XIAO_KE = "mine_xiaozi"
let IMAGE_MINE_SETTINGS = "mine_settings"
let IMAGE_MINE_FEEDBACK = "mine_feedback"
let IMAGE_AVATAR = "avator"
let IMAGE_MYCAR_HISTORY = "mycar_history"
let IMAGE_MYCAR_XINGNENG = "mycar_xingneng"
let IMAGE_MYCAR_XINPIN = "mycar_xinpin"
let IMAGE_CAR_IMAGE = "car_avator"
let IMAGE_QRCODE = "qrcode"
let IMAGE_POSITION_FEMALE_RED = "position_female_red"
let IMAGE_POSITION_MALE_WHITE = "position_male_white"

let FIR_APP_ID = "552a3921ebc861d936002615"
let FIR_USER_TOKEN = "3af74030cca511e4a5e787e903cd690d43148e64"
let FIR_URL_VERSION_CHECK = "http://fir.im/api/v2/app/version/" + FIR_APP_ID + "?token=" + FIR_USER_TOKEN
let FIR_URL_DOWNLOAD = "itms-services://?action=download-manifest&url="

func UIColorFromRGB(rgbValue: UInt) -> UIColor {
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}