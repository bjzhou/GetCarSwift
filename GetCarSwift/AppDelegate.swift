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

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        if let _ = Mine.sharedInstance.token {
            if Mine.sharedInstance.nickname.trim() == "" {
                let firstController = UINavigationController(rootViewController: R.storyboard.login.register()!)
                firstController.navigationItem.title = "登录"
                window?.rootViewController = firstController
            }
        } else {
            window?.rootViewController = R.storyboard.login.login()
        }
        
        if AppDelegate.debugLogin {
            window?.rootViewController = R.storyboard.login.login()
        }
        
        if AppDelegate.debugRegister {
            window?.rootViewController = R.storyboard.login.register()
        }
        
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().barTintColor = UIColor.black
        UINavigationBar.appearance().barStyle = .black
        
        UITabBar.appearance().isTranslucent = false
        UITabBar.appearance().barTintColor = UIColor.black
        UITabBar.appearance().tintColor = UIColor.gaikeRedColor()
        
        AMapServices.shared().apiKey = amapKey
        
        Bugly.setUserIdentifier(Mine.sharedInstance.nickname)
        Bugly.start(withAppId: buglyAppid)
        WXApi.registerApp(wechatKey)
        
        RCIM.shared().initWithAppKey(rongAppKey)
        
        let settings = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil)
        application.registerUserNotificationSettings(settings)
        
        RCIMClient.shared().recordLaunchOptionsEvent(launchOptions)
        let pushServiceData = RCIMClient.shared().getPushExtra(fromLaunchOptions: launchOptions)
        if (pushServiceData != nil) {
            print("launch from push service")
            print(pushServiceData)
        }
        
        if let remoteNotificationUserInfo = launchOptions?[.remoteNotification] as? [String:Any], let rc = remoteNotificationUserInfo["rc"] as? [String:String], let targetId = rc["fId"] {
            main {
                if let mainVc = self.window?.rootViewController as? MainViewController, let navVc = mainVc.selectedViewController as? UINavigationController, let vc = navVc.visibleViewController {
                    //                    if UIApplication.sharedApplication().applicationState == .Active {
                    //                        if let conversationVc = vc as? ConversationViewController where targetId == conversationVc.targetId {
                    //                            // in chatting, do nothing
                    //                        } else {
                    //                            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                    //                        }
                    //                    }
                    let chat = ConversationViewController()
                    chat.hidesBottomBarWhenPushed = true
                    chat.conversationType = .ConversationType_PRIVATE
                    chat.targetId = targetId
                    vc.showViewController(chat)
                }
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(RCConversationListViewController.didReceiveMessageNotification(_:)), name: NSNotification.Name.RCKitDispatchMessage, object: nil)
        
        RCIM.shared().userInfoDataSource = self
        
        Realm.Configuration.defaultConfiguration = Realm.Configuration(
            schemaVersion: 28,
            migrationBlock: { migration, oldSchemaVersion in
        })
        
        if let logs = gRealm?.objects(RmLog.self) {
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
        _ = FIR.checkUpdate().subscribe(onNext: { fir in
            if version < fir.version {
                let alert = UIAlertController(title: "更新", message: "当前版本：" + versionShort! + "\n最新版本：" + fir.versionShort + "\n版本信息：" + fir.changelog + "\n\n是否下载安装最新版本？", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "安装", style: .default, handler: { (action) in
                    UIApplication.shared.openURL(NSURL(string: fir.updateUrl)! as URL)
                }))
                self.window?.rootViewController?.present(alert, animated: true, completion: nil)
            }
        })
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        let count = Int(RCIMClient.shared().getTotalUnreadCount())
        application.applicationIconBadgeNumber = count
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        application.registerForRemoteNotifications()
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.description.replacingOccurrences(of: "<", with: "").replacingOccurrences(of: ">", with: "").replacingOccurrences(of: " ", with: "")
        RCIMClient.shared().setDeviceToken(token)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        RCIMClient.shared().recordRemoteNotificationEvent(userInfo)
        let pushServiceData = RCIMClient.shared().getPushExtra(fromRemoteNotification: userInfo)
        if pushServiceData != nil {
            print("received remote notification")
            print(pushServiceData)
        }
    }

    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        RCIMClient.shared().recordLocalNotificationEvent(notification)
    }

    func didReceiveMessageNotification(_ notification: UIKit.Notification) {
//        if let msg = notification.object as? RCMessage {
//        }
    }

    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        return WXApi.handleOpen(url, delegate: self)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return WXApi.handleOpen(url, delegate: self)
    }

    func onReq(_ req: BaseReq!) {
        print(req.type, req.openID)
    }

    func onResp(_ resp: BaseResp!) {
        print(resp.errCode, resp.errStr, resp.type)
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.RCKitDispatchMessage, object: nil)
    }
}

extension AppDelegate: RCIMUserInfoDataSource {
    func getUserInfo(withUserId userId: String!, completion: ((RCUserInfo?) -> Void)!) {
        _ = User.getUserInfo(userId).subscribe(onNext: { res in
            guard let user = res.data else {
                return
            }
            let userInfo = RCUserInfo(userId: userId, name: user.nickname, portrait: user.img)
            completion(userInfo)
        })
    }
}
