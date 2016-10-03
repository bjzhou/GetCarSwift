//
//  Globals.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/4/11.
//  Copyright (c) 2015年 周斌佳. All rights reserved.
//

import Foundation

let versionShort = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
let version = Int(Bundle.main.infoDictionary!["CFBundleVersion"] as? String ?? "")!
let bundleId = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String
let productName = Bundle.main.infoDictionary?["CFBundleName"] as? String

#if ADHOC
    let amapKey = "5f7efffc934719c87faca88c9cea88ec"
    let buglyAppid = "900011518"
    let rongAppKey = "sfci50a7czjxi"
#else
    let amapKey = "751ca4d9d8c3a9bd8ef2e2b64a8e7cb4"
    let buglyAppid = "900007462"
    let rongAppKey = "sfci50a7czjxi"
#endif

let wechatKey = "wx9cd191a47cee9ac6"

let alertStr = NSAttributedString.loadHTMLString("<font size=4>在通过设定的起点和终点时将会自动启动与结束码表，不用手动启动与结束。<br/><br/>进入计时前，请仔细阅读<b>《使用条款以及免责声明》</b>。进入计时，即视为认同我司的<b>《使用条款以及免责声明》</b></font>")

/*
获得地图界面定位图标名
sex: 性别，0男/1女
color:颜色类型，101-110
icon:图标类型，201-206
*/
func getCarIconName(_ sex: Int, color: Int, icon: Int) -> String {
    return getSexString(sex) + "  " + getColorByTag(color) + getIconString(icon) + " 选中"
}

func getNoSexCarIconName(_ color: Int, icon: Int) -> String {
    return getColorByTag(color) + getIconString(icon)
}

/*
获得颜色图标名
sex: 性别，0男/1女
color:颜色类型，101-110
*/
func getColorIconName(_ sex: Int, color: Int) -> String {
    return getSexString(sex) + "  " + getColorByTag(color) + " 选中"
}

func getColorByTag(_ tag: Int) -> String {
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

func getSexString(_ sex: Int) -> String {
    return sex == 1 ? "男" : "女"
}

func getIconString(_ icon: Int) -> String {
    return icon < 200 ? "1" : String(icon - 200)
}

func getSmallHomepageBg(_ index: Int) -> String {
    return "homepage_bg" + String(index) + "_small"
}

func getHomepageBg(_ index: Int) -> String {
    return "homepage_bg" + String(index)
}
