//
//  Globals.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/4/11.
//  Copyright (c) 2015年 周斌佳. All rights reserved.
//

import Foundation

let VERSION_SHORT = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String
let VERSION = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as? String

let AMAP_KEY = "751ca4d9d8c3a9bd8ef2e2b64a8e7cb4"
let BUGLY_APPID = "900007462"

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
        return "红"
    }
}

func getSexString(sex: Int) -> String {
    return sex == 1 ? "男" : "女"
}

func getIconString(icon: Int) -> String {
    return icon < 200 ? "1" : String(icon - 200)
}

func getSmallHomepageBg(index: Int) -> String {
    return "homepage_bg" + String(index) + "_small"
}

func getHomepageBg(index: Int) -> String {
    return "homepage_bg" + String(index)
}






