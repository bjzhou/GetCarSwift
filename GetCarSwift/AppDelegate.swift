//
//  AppDelegate.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/4/11.
//  Copyright (c) 2015年 周斌佳. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    static let debugLogin = false
    static let debugRegister = false

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        if let _ = Mine.sharedInstance.token {
            if let nickname = Mine.sharedInstance.nickname where nickname.trim() != "" {} else {
                let firstController = UINavigationController(rootViewController: R.storyboard.login.register!)
                firstController.navigationItem.title = "登录"
                window?.rootViewController = firstController
            }
        } else {
            window?.rootViewController = R.storyboard.login.login
        }

        if AppDelegate.debugLogin {
            window?.rootViewController = R.storyboard.login.login
        }

        if AppDelegate.debugRegister {
            window?.rootViewController = R.storyboard.login.register
        }

        UINavigationBar.appearance().translucent = false
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().barTintColor = UIColor.blackColor()
        UINavigationBar.appearance().barStyle = .Black

        UITabBar.appearance().translucent = false
        UITabBar.appearance().barTintColor = UIColor.blackColor()
        UITabBar.appearance().tintColor = UIColor.gaikeRedColor()

        MAMapServices.sharedServices().apiKey = amapKey
        AMapSearchServices.sharedServices().apiKey = amapKey
        AMapLocationServices.sharedServices().apiKey = amapKey

        CrashReporter.sharedInstance().enableBlockMonitor(true)
        CrashReporter.sharedInstance().setUserId(Mine.sharedInstance.nickname ?? "10000")
        CrashReporter.sharedInstance().installWithAppId(buglyAppid)

        RCIM.sharedRCIM().initWithAppKey(rongAppKey)

        Realm.Configuration.defaultConfiguration = Realm.Configuration(
            schemaVersion: 20,
            migrationBlock: { migration, oldSchemaVersion in
                if (oldSchemaVersion < 20) {
                    migration.enumerate(RmLog.className()) { oldObject, newObject in
                        let timeStr = oldObject!["time"] as? String
                        let dateFormatter = NSDateFormatter()
                        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
                        print(timeStr)
                        print(dateFormatter.dateFromString(timeStr!))
                        if let date = dateFormatter.dateFromString(timeStr!) {
                            newObject!["time"] = date
                        }
                    }
                }
        })

        if let logs = gRealm?.objects(RmLog), firstLog = logs.first {
            let time = -firstLog.time.timeIntervalSinceNow
            print(time)
            if time >= 7 * 24 * 60 * 60 {
                gRealm?.writeOptional {
                    gRealm?.delete(logs)
                }
            }
        }

        #if ADHOC
            checkNewVersion()
        #endif

        return true
    }

    func checkNewVersion() {
        _ = FIR.checkUpdate().subscribeNext { fir in
            if version < fir.version {
                let alert = UIAlertController(title: "更新", message: "当前版本：" + versionShort! + "\n最新版本：" + fir.versionShort + "\n版本信息：" + fir.changelog + "\n\n是否下载安装最新版本？", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "安装", style: .Default, handler: { (action) in
                    UIApplication.sharedApplication().openURL(NSURL(string: fir.updateUrl)!)
                }))
                self.window?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}
