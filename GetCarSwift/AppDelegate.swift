//
//  AppDelegate.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/4/11.
//  Copyright (c) 2015年 周斌佳. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let defaults = NSUserDefaults.standardUserDefaults()
        if !defaults.boolForKey("isLogin") {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginController = storyboard.instantiateViewControllerWithIdentifier("login")
            window?.rootViewController = loginController
        }
        
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().barTintColor = UI_COLOR_RED
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor(), NSFontAttributeName : UIFont.systemFontOfSize(20.0)]
        UINavigationBar.appearance().barStyle = .Black
        
        UITabBar.appearance().tintColor = UI_COLOR_RED
        
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.whiteColor()
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.darkGrayColor()
        
        MAMapServices.sharedServices().apiKey = "751ca4d9d8c3a9bd8ef2e2b64a8e7cb4"
        
        checkNewVersion()
        
        return true
    }
    
    func checkNewVersion() {
        checkUpdate().responseJSON { (req, res, data) in
            guard let jsonValue = data.value else {
                print(data.error?.description)
                return
            }
            let fir = FIR(json: jsonValue)
            if VERSION != fir.version {
                let alert = UIAlertController(title: "更新", message: "当前版本：" + VERSION_SHORT! + "\n最新版本：" + fir.versionShort + "\n版本信息：" + fir.changelog + "\n\n是否下载安装最新版本？", preferredStyle: .Alert)
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

