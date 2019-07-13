//
//  AppDelegate.swift
//  Aces
//
//  Created by Kyle Workman on 6/14/18.
//  Copyright © 2018 Kyle Workman. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import FirebaseRemoteConfig
import GoogleSignIn
import GoogleMaps
import GooglePlaces
import Toast_Swift
import UserNotifications
import FirebaseInstanceID
import FirebaseMessaging

//    FIRAuth.auth()?.addStateDidChangeListener { auth, user in
//    if let user = user {
//    // User is signed in.
//    } else {
//    // No user is signed in.
//    }
//    }

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISearchBarDelegate, GIDSignInDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    var window: UIWindow?
    var email: String = ""
    var token: String = " "
    let gcmMessageIDKey = "gcm.message_id"
    var needUpdate: Bool = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        let _ = RCValues.sharedInstance
        
        Messaging.messaging().delegate = self
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        application.registerForRemoteNotifications()
        
        // Configure Firebase and Google services
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        GMSServices.provideAPIKey("")
        GMSPlacesClient.provideAPIKey("")
        if GIDSignIn.sharedInstance().hasAuthInKeychain() {
            let mainStoryboardIpad : UIStoryboard = UIStoryboard(name: "LaunchScreen", bundle: nil)
            let initialViewControlleripad : UIViewController = mainStoryboardIpad.instantiateViewController(withIdentifier: "launch") as UIViewController
            self.window = UIWindow(frame: UIScreen.main.bounds)
            self.window?.rootViewController = initialViewControlleripad
            self.window?.makeKeyAndVisible()
            GIDSignIn.sharedInstance().signInSilently()
        } else {
            let mainStoryboardIpad : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let initialViewControlleripad : UIViewController = mainStoryboardIpad.instantiateViewController(withIdentifier: "signin") as UIViewController
            self.window = UIWindow(frame: UIScreen.main.bounds)
            self.window?.rootViewController = initialViewControlleripad
            self.window?.makeKeyAndVisible()
        }
        return true
    }
    
    // Handle Google/Firebase sign in
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (!needUpdate) {
        // Cancelled Google sign in
        if let err = error {
            print("GOOGLE SIGN IN \(err)")
            self.window?.rootViewController?.view.hideToastActivity()
            self.window?.rootViewController?.view.isUserInteractionEnabled = true
            if (!err.localizedDescription.contains("The user canceled")) {
                displayConnectionError()
            }
            return
        }
        
        // Successful Google sign in
        guard let idToken = user.authentication.idToken else { return }
        guard let accessToken = user.authentication.accessToken else { return }
        let credentials = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        
        // Authenticate with Firebase
        Auth.auth().signInAndRetrieveData(with: credentials, completion: { (user, error) in
            
            // Error authenticating with Firebase
            if let err = error {
                print("FIREBASE SIGN IN \(err)")
                self.displayConnectionError()
                return
            }
            
            // Successful Firebase authentication
            guard let userUnwrapped = Auth.auth().currentUser else {return}
            self.email = userUnwrapped.email!
            
            // Check if Augustana email address
            if (self.email.contains("@augustana.edu")) {
                let mainStoryboardIpad : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let initialViewControlleripad : UIViewController = mainStoryboardIpad.instantiateViewController(withIdentifier: "map") as UIViewController
                self.window = UIWindow(frame: UIScreen.main.bounds)
                self.window?.rootViewController = initialViewControlleripad
                self.window?.makeKeyAndVisible()
            } else { // Not Augustana email address, force sign out
                self.window?.rootViewController?.view.hideToastActivity()
                self.window?.rootViewController?.view.isUserInteractionEnabled = true
                self.window?.makeToast("Must login with Augustana email!", position: .bottom)
                GIDSignIn.sharedInstance().signOut()
            }
        })
        }
    }
    
    func displayConnectionError() {
        let alert = UIAlertController(title: "Connection Error", message: "Please check your internet connection", preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Retry", style: UIAlertActionStyle.default, handler: { (alert) -> Void in
            if GIDSignIn.sharedInstance().hasAuthInKeychain() {
                GIDSignIn.sharedInstance().signInSilently()
            }
        })
        alert.addAction(action)
        DispatchQueue.main.async(execute: {
            self.window?.rootViewController?.present(alert, animated: true, completion: nil)
        })
    }
    
    // Handle URL for Google sign in
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any])
        -> Bool {
            return GIDSignIn.sharedInstance().handle(url,
                                                     sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                                     annotation: [:])
    }
    
    func triggerFetched() {
        let updateRequired = RemoteConfig.remoteConfig().configValue(forKey: "force_update_required").boolValue
        if (updateRequired) {
            let cloudVersion = RemoteConfig.remoteConfig()
                .configValue(forKey: "force_update_version_ios")
                .stringValue?
                .replacingOccurrences(of: ".", with: "")
            let currentVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
            let cloudNum: Int = Int(cloudVersion!)! // firstText is UITextField
            let currentNum: Int = Int(currentVersion.replacingOccurrences(of: ".", with: ""))!
            if (currentNum < cloudNum) {
                self.window?.rootViewController?.view.isUserInteractionEnabled = false
                updateAlert()
                needUpdate = true
            }
        }
    }
    
    func updateAlert() {
        let alert = UIAlertController(title: "Required Update", message: "Please update the app to continue using ACES.", preferredStyle: UIAlertControllerStyle.alert)
        let update = UIAlertAction(title: "Update", style: UIAlertActionStyle.default, handler: { action in
            let link = "https://itunes.apple.com/us/app/aces-augustana-college/id1437441626?ls=1&mt=8"
            if let url = URL(string: link), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: {(success: Bool) in
                    if success {
                        print("Launch successful")
                    }
                })
            }
        })
        alert.addAction(update)
        DispatchQueue.main.async(execute: {
            self.window?.rootViewController?.present(alert, animated: true, completion: nil)
        })
    }
    
    func getEmail() -> String {
        return email
    }
    
    func getToken() -> String {
        return token
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        NSLog("background")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        if (needUpdate) {
            self.window?.rootViewController?.view.isUserInteractionEnabled = false
            updateAlert()
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Aces")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("REMOTE MESSAGE")
        print(remoteMessage.appData)
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        
        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        token = fcmToken
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        print("deviceTokenString: \(deviceTokenString)")
        
        //set apns token in messaging
        Messaging.messaging().apnsToken = deviceToken
    }
    
    @available(iOS 10, *)
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        // Change this to your preferred presentation option
        completionHandler([.alert, .badge, .sound])
    }
    
    @available(iOS 10, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        completionHandler()
    }
    
    
}

