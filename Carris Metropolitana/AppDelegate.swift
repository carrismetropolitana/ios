//
//  AppDelegate.swift
//  Carris Metropolitana
//
//  Created by João Pereira on 18/07/2024.
//

import SwiftUI
import FirebaseCore
import FirebaseMessaging
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        }
        
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        
        return true
    }
    
//    func applicationDidBecomeActive(_ application: UIApplication) {
//        clearBadge()
//    }
//
//    func applicationWillEnterForeground(_ application: UIApplication) {
//        clearBadge()
//    }
//    
//    func clearBadge() {
//        DispatchQueue.main.async {
//            UIApplication.shared.applicationIconBadgeNumber = -1
//            UNUserNotificationCenter.current().setBadgeCount(-1) { (error) in
//                if let error = error {
//                    print("Error clearing badge: \(error.localizedDescription)")
//                }
//            }
//        }
//    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("Device push notification (APNs) token: \(tokenString)")
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error)")
    }
    
    @objc func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Received FCM token: \(String(describing: fcmToken))")
        messaging.subscribe(toTopic: "cm.everyone") // general topic for broadcasting messages to every user
    }
    
//    private func setupNetworkMonitoring() {
//       NotificationCenter.default.addObserver(self, selector: #selector(networkStatusChanged), name: .networkStatusChanged, object: nil)
//   }
//    
//    @objc private func networkStatusChanged() {
//        if NetworkMonitor.shared.isConnected {
//            print("Back up online")
//        } else {
//            print("Went offline")
//        }
//    }
       
}
