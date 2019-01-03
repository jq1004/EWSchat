//
//  AppDelegate.swift
//  EarlyWarningSystem
//
//  Created by Junqing li on 12/23/18.
//  Copyright © 2018 Junqing li. All rights reserved.
//

import UIKit
import Firebase
import GoogleMaps
import GooglePlaces
import Crashlytics
import Fabric
import UserNotifications



let primaryColor = UIColor(red: 210/255, green: 109/255, blue: 180/255, alpha: 1)
let secondaryColor = UIColor(red: 52/255, green: 148/255, blue: 230/255, alpha: 1)
let Appkey = "588f7833a3fc273c038b4849"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let setting = UNUserNotificationCenter.current()
        setting.requestAuthorization(options: [.alert,.sound,.badge]) { (granted, error) in
            
            if granted {
                print("Allowed")
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                
            }else{
                print("Not Allowed")
            }
            
        }
        
//        Fabric.with([Crashlytics.self])
        
        //Google Service
        GMSServices.provideAPIKey("AIzaSyDe7U8s0GazusymzJ752U3NPDn0KXHRYLk")
        GMSPlacesClient.provideAPIKey("AIzaSyDe7U8s0GazusymzJ752U3NPDn0KXHRYLk")
        
        FirebaseApp.configure()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        if Auth.auth().currentUser?.uid != nil {
            let homeController = MainTabController()
            window?.rootViewController = homeController

        } else{
            let loginController = LoginController()
            window?.rootViewController = UINavigationController(rootViewController: loginController)
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let varAvgvalue = String(format: "%@", deviceToken as CVarArg)
        
        let  token = varAvgvalue.trimmingCharacters(in: CharacterSet(charactersIn: "<>")).replacingOccurrences(of: " ", with: "")
        
        print(token)
        PushWizard.start(withToken: deviceToken, andAppKey: Appkey, andValues: nil)
        
    }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
        print(error.localizedDescription)
        
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        print(userInfo)
       PushWizard.handleNotification(userInfo, processOnlyStatisticalData: false)
        
    }
    

}

