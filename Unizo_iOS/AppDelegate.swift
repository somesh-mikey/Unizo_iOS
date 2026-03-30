//
//  AppDelegate.swift
//  Unizo_iOS
//
//  Created by Somesh on 11/11/25.
//

import UIKit
import Supabase
import UserNotifications

let supabase = SupabaseClient(
    supabaseURL: URL(string: "https://tcaqxwxlrfoxmthigjgd.supabase.co")!,
    supabaseKey: "sb_publishable_17MrI1DzB2mXj9mbzERurw_kXDz0tZi"
)

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.delegate = self

        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("AppDelegate: Notification permission request failed: \(error)")
                return
            }
            print("AppDelegate: Notification permission granted: \(granted)")
        }

        return true
    }

    // Show native iOS notification banners while app is in foreground.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .list, .sound])
    }

    // Route notification tap to the right screen.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo

        Task { @MainActor in
            let type = userInfo["type"] as? String

            if type == "chat",
               let conversationIdString = userInfo["conversationId"] as? String,
               let conversationId = UUID(uuidString: conversationIdString) {
                ChatManager.shared.openChatFromNotification(conversationId: conversationId)
                completionHandler()
                return
            }

            if type == "order" {
                let route = (userInfo["route"] as? String) ?? ""
                let orderIdString = userInfo["orderId"] as? String
                let orderId = orderIdString.flatMap(UUID.init)
                NotificationManager.shared.navigateToRoute(route: route, orderId: orderId)
                completionHandler()
                return
            }

            completionHandler()
        }
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

