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
let IMAGE_AVATAR = "avator"
let IMAGE_MYCAR_HISTORY = "mycar_history"
let IMAGE_MYCAR_XINGNENG = "mycar_xingneng"
let IMAGE_MYCAR_XINPIN = "mycar_xinpin"
let IMAGE_QRCODE = "qrcode"
let IAMGE_ACCESSORY = "accessory"
let IAMGE_ACCESSORY_SELECTED = "accessory_selected"
let IMAGE_CAR_INFO_AREA = "car_info_area"
let IMAGE_CAR_INFO_AREA_PRESSED = "car_info_area_pressed"

let FIR_APP_ID = "552a3921ebc861d936002615"
let FIR_USER_TOKEN = "3af74030cca511e4a5e787e903cd690d43148e64"
let FIR_URL_VERSION_CHECK = "http://fir.im/api/v2/app/version/" + FIR_APP_ID + "?token=" + FIR_USER_TOKEN
let FIR_URL_DOWNLOAD = "itms-services://?action=download-manifest&url="

/*
    获得地图界面定位图标名
    sex: 性别，0男/1女
    color:颜色类型，101-110
    icon:图标类型，201-206
*/
func getCarIconName(sex: Int, color: Int, icon: Int) -> String {
    return getSexString(sex) + "  " + getColorByTag(color) + getIconString(icon) + " 选中"
}

func getNoSexCarIconName(color: Int, icon: Int) -> String {
    return getColorByTag(color) + getIconString(icon)
}

/*
    获得颜色图标名
    sex: 性别，0男/1女
    color:颜色类型，101-110
*/
func getColorIconName(sex: Int, color: Int) -> String {
    return getSexString(sex) + "  " + getColorByTag(color) + " 选中"
}

func getColorByTag(tag: Int) -> String {
    switch tag {
    case 0:
        // default value
        return "红"
    case 101:
        return "红"
    case 102:
        return "蓝"
    case 103:
        return "白"
    case 104:
        return "银"
    case 105:
        return "灰"
    case 106:
        return "黑"
    case 107:
        return "黄"
    case 108:
        return "绿"
    case 109:
        return "紫"
    default:
        return "其他"
    }
}

func getSexString(sex: Int) -> String {
    return sex == 0 ? "男" : "女"
}

func getIconString(icon: Int) -> String {
    return icon == 0 ? "1" : String(icon - 200)
}

func getSmallHomepageBg(index: Int) -> String {
    return "homepage_bg" + String(index) + "_small"
}

func getHomepageBg(index: Int) -> String {
    return "homepage_bg" + String(index)
}
