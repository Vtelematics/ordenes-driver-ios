//

//  AppDelegate.swift
//  FoodDelivery
//
//  Created by Adyas Iinfotech on 16/03/18.
//  Copyright © 2018 Adyas Iinfotech. All rights reserved.
//

import UIKit
import UserNotifications
import IQKeyboardManagerSwift
import Alamofire
import GoogleMaps
import GooglePlaces
import OneSignal
import Reachability
import Firebase

var userIDStr:String = ""
var notificationId:String = ""
let kUserDetails:String = "_k_USER_DETAILS"
var themeColor = UIColor ()
var positiveBtnColor = UIColor()
var negativeBtnColor = UIColor ()
var driverLatitude = Double()
var driverLongitude = Double()
var orderIdToUpdate : String = ""
var isBackGroundMode = false
var languageID:String = "1"
var languageCode:String = "en"
var isUpdateTheApp = true
var apiKey = "AIzaSyDrb4lQdX93xFN8emW6q1fdglaDSqTAzSI"
var isRTLenabled : Bool = false
//var notifyKey = false
//var delvieryVCNotifyKey = false
//var foreground = false

extension Notification.Name {
    static let enableBackgroundMode = Notification.Name("enableBackgroundMode")
    static let disableBackgroundMode = Notification.Name("disableBackgroundMode")
    static let changeLanguage = Notification.Name("add_change_lang")
    static let enableBackgroundNotification = Notification.Name("enableBackgroundNotification")
}

enum VersionError: Error {
    case invalidResponse, invalidBundleInfo
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate
{
    var window: UIWindow?
    internal func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Base Theme
        themeColor = UIColor(red: 195/255.0, green: 31/255.0, blue: 38.0/255.0, alpha: 1.0)
        positiveBtnColor = UIColor(red: 255/255, green: 90/255, blue: 1/255, alpha: 1.0)
        negativeBtnColor = UIColor.darkGray
        // Navigation Bar
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = themeColor
            appearance.titleTextAttributes = [.font:
            UIFont.boldSystemFont(ofSize: 20.0),
                                          .foregroundColor: UIColor.white]
            UINavigationBar.appearance().tintColor = .white
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        } else {
            UINavigationBar.appearance().barTintColor = themeColor
            UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
            UINavigationBar.appearance().tintColor = UIColor.white
            UINavigationBar.appearance().isTranslucent = false
        }
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.toolbarTintColor = themeColor
        // Google Maps
        GMSServices.provideAPIKey(apiKey)
        GMSPlacesClient.provideAPIKey(apiKey)
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let userId = UserDefaults.standard.string(forKey: "USER_ID"), userId != "" {
            userIDStr = userId
            let viewController = storyboard.instantiateViewController(withIdentifier: "HomeViewController")
            let navigationController = UINavigationController.init(rootViewController: viewController)
            self.window?.rootViewController = navigationController
            self.window?.makeKeyAndVisible()
            
        } else {
            let viewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
            let navigationController = UINavigationController.init(rootViewController: viewController)
            self.window?.rootViewController = navigationController
            self.window?.makeKeyAndVisible()
        }
        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: true]
        
        OneSignal.initWithLaunchOptions(launchOptions,
                                        appId: "5f274bfa-c517-4227-a602-5d5f633712f6",
                                        handleNotificationReceived: { notification in
//                                            if notification?.payload.additionalData != nil {
//                                                let additionalData = notification?.payload.additionalData
//                                                if let orderStatusId = (additionalData!["order_status_id"])
//                                                {
//                                                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                                                    let initialViewController = storyboard.instantiateViewController(withIdentifier: "UnassignOrderViewController") as! UnassignOrderViewController
//                                                    self.window?.rootViewController = initialViewController
//                                                    self.window?.makeKeyAndVisible()
//                                                }else
//                                            }
                                        },
                                        handleNotificationAction: nil,
                                        settings: onesignalInitSettings)
        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification;
        
        OneSignal.promptForPushNotifications(userResponse: { accepted in
            print("User accepted notifications: \(accepted)")
        })
        
        let status: OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
        if let id = status.subscriptionStatus.userId {
            notificationId = id
            OneSignal.sendTag("delivery_user_id", value: "\(notificationId)")
        }
          
        if let id = UserDefaults.standard.string(forKey: "language_id")
        {
            if id != ""
            {
                languageID = id
                languageCode = UserDefaults.standard.object(forKey: "language_code") as! String
            }
            else
            {
                languageID = "1"
                languageCode = "en"
            }
        }
        else
        {
            languageID = "1"
            languageCode = "en"
        }
        UserDefaults.standard.set(languageID, forKey: "language_id")
        UserDefaults.standard.set(languageCode, forKey: "language_code")
        FirebaseApp.configure()
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        if let userId = UserDefaults.standard.string(forKey: "USER_ID"), userId != ""{
            if let status = UserDefaults.standard.string(forKey: "SHIFT_STATUS"), status != "", status == "1" {
                isBackGroundMode = true
                NotificationCenter.default.post(name: .enableBackgroundMode, object: nil)
            }else{
                NotificationCenter.default.post(name: .disableBackgroundMode, object: nil)
            }
        }
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        if let userId = UserDefaults.standard.string(forKey: "USER_ID"), userId != ""{
            if let status = UserDefaults.standard.string(forKey: "SHIFT_STATUS"), status != "", status == "1" {
                isBackGroundMode = true
                NotificationCenter.default.post(name: .enableBackgroundNotification, object: nil)
            }
        }
    }
    
    // Push notification received
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        completionHandler(.newData)
        if application.applicationState == UIApplication.State.active {
            print("UIApplication.State.active")
        }else {
            if let value = userInfo["custom"] {
                let detailDic = value as! NSDictionary
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let userId = UserDefaults.standard.string(forKey: "USER_ID"), userId != ""{
                    userIDStr = userId
                    if let orderIdDic = detailDic["a"] as? NSDictionary{
                        let orderStatusId = "\(orderIdDic["order_status_id"]!)"
                        if orderStatusId == "3" {
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let viewController = storyboard.instantiateViewController(withIdentifier: "UnassignOrderViewController") as! UnassignOrderViewController
                            let navigationController = UINavigationController.init(rootViewController: viewController)
                            viewController.fromNotification = true
                            self.window?.rootViewController = navigationController
                            self.window?.makeKeyAndVisible()
                        }else{
                            
                            let viewController = storyboard.instantiateViewController(withIdentifier: "HomeViewController")
                            let navigationController = UINavigationController.init(rootViewController: viewController)
                            self.window?.rootViewController = navigationController
                            self.window?.makeKeyAndVisible()
                        }
                    }
                }else{
                    let viewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
                    let navigationController = UINavigationController.init(rootViewController: viewController)
                    self.window?.rootViewController = navigationController
                    self.window?.makeKeyAndVisible()
                }
            }else {
                print("other notification / message")
            }
        }
    }
}

