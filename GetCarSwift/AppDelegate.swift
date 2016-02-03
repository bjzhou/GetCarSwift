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
import AudioToolbox

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WXApiDelegate {

    static let debugLogin = false
    static let debugRegister = false

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        if let _ = Mine.sharedInstance.token {
            if Mine.sharedInstance.nickname.trim() == "" {
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
        WXApi.registerApp(wechatKey)

        RCIM.sharedRCIM().initWithAppKey(rongAppKey)

        let settings = UIUserNotificationSettings(forTypes: [.Badge, .Sound, .Alert], categories: nil)
        application.registerUserNotificationSettings(settings)

        RCIMClient.sharedRCIMClient().recordLaunchOptionsEvent(launchOptions)
        let pushServiceData = RCIMClient.sharedRCIMClient().getPushExtraFromLaunchOptions(launchOptions)
        if (pushServiceData != nil) {
            print("launch from push service")
            print(pushServiceData)
        }

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveMessageNotification:", name: RCKitDispatchMessageNotification, object: nil)

        RCIM.sharedRCIM().userInfoDataSource = self

        Realm.Configuration.defaultConfiguration = Realm.Configuration(
            schemaVersion: 28,
            migrationBlock: { migration, oldSchemaVersion in
        })

        if let logs = gRealm?.objects(RmLog) {
            gRealm?.writeOptional {
                gRealm?.delete(logs)
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
        let count = Int(RCIMClient.sharedRCIMClient().getTotalUnreadCount())
        application.applicationIconBadgeNumber = count
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

    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        application.registerForRemoteNotifications()
    }

    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let token = deviceToken.description.stringByReplacingOccurrencesOfString("<", withString: "").stringByReplacingOccurrencesOfString(">", withString: "").stringByReplacingOccurrencesOfString(" ", withString: "")
        RCIMClient.sharedRCIMClient().setDeviceToken(token)
    }

    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        RCIMClient.sharedRCIMClient().recordRemoteNotificationEvent(userInfo)
        let pushServiceData = RCIMClient.sharedRCIMClient().getPushExtraFromRemoteNotification(userInfo)
        if pushServiceData != nil {
            print("received remote notification")
            print(pushServiceData)
        }
        print("didReceiveRemoteNotification")
    }

    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        RCIMClient.sharedRCIMClient().recordLocalNotificationEvent(notification)
        print("didReceiveLocalNotification")
    }

    func didReceiveMessageNotification(notification: NSNotification) {
        if let msg = notification.object as? RCMessage {
            main {
                if let mainVc = self.window?.rootViewController as? MainViewController, navVc = mainVc.selectedViewController as? UINavigationController, vc = navVc.visibleViewController {
                    if UIApplication.sharedApplication().applicationState == .Active {
                        if let conversationVc = vc as? ConversationViewController where msg.targetId == conversationVc.targetId {
                            // in chatting, do nothing
                        } else {
                            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                        }
                    } else {
                        let chat = ConversationViewController()
                        chat.hidesBottomBarWhenPushed = true
                        chat.conversationType = msg.conversationType
                        chat.targetId = msg.targetId
                        vc.showViewController(chat)
                    }
                }
            }
        }
    }

    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        return WXApi.handleOpenURL(url, delegate: self)
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return WXApi.handleOpenURL(url, delegate: self)
    }

    func onReq(req: BaseReq!) {
        print(req.type, req.openID)
    }

    func onResp(resp: BaseResp!) {
        print(resp.errCode, resp.errStr, resp.type)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: RCKitDispatchMessageNotification, object: nil)
    }
}

extension AppDelegate: RCIMUserInfoDataSource {
    func getUserInfoWithUserId(userId: String!, completion: ((RCUserInfo!) -> Void)!) {
        let userInfo = RCUserInfo(userId: userId, name: "test", portrait: "https://www.sogou.com/images/index/wangan.png")
        completion(userInfo)
    }
}
