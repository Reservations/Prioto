//
//  AppDelegate.swift
//  Prioto
//
//  Created by Kha Nguyen on 7/11/16.
//  Copyright © 2016 Kha. All rights reserved.
//

import UIKit
import IQKeyboardManager
import SwiftyUserDefaults
import BSForegroundNotification
import PopupDialog
import RealmSwift
import Realm
import AudioToolbox

extension DefaultsKeys {
	static let dateAppExited = DefaultsKey<NSDate>("dateAppExited")
}

public var hasExitedAppAndGoBack: Bool = false

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, BSForegroundNotificationDelegate {


	var window: UIWindow?
	var localNotification: UILocalNotification!

	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		// Override point for customization after application launch.
		
		let config = Realm.Configuration(
			// Set the new schema version. This must be greater than the previously used
			// version (if you've never set a schema version before, the version is 0).
			schemaVersion: 2,
			
			// Set the block which will be called automatically when opening a Realm with
			// a schema version lower than the one set above
			migrationBlock: { migration, oldSchemaVersion in
    // We haven’t migrated anything yet, so oldSchemaVersion == 0
    if (oldSchemaVersion < 2) {
		// Nothing to do!
		// Realm will automatically detect new properties and removed properties
		// And will update the schema on disk automatically
    }
  })
		
		// Tell Realm to use this new configuration object for the default Realm
		Realm.Configuration.defaultConfiguration = config
		
		// Now that we've told Realm how to handle the schema change, opening the file
		// will automatically perform the migration
		let realm = try! Realm()

		IQKeyboardManager.sharedManager().enable = true
		IQKeyboardManager.sharedManager().shouldResignOnTouchOutside = true
		// types are UIUserNotificationType values
		// application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil))

		if let tabBarController = self.window!.rootViewController as? UITabBarController {
			for viewController in tabBarController.viewControllers! {
				if let view = viewController.topViewController()  {
					view.view.description
				}
			}
		}
		
		UIApplication.sharedApplication().statusBarStyle = .LightContent		
//		let tabBarController = self.window!.rootViewController as! UITabBarController
//		for viewController in tabBarController.viewControllers! {
//			let aView = viewController.topViewController as! UIViewController
//			aView.view.description
//		}
		
		NSNotificationCenter.defaultCenter().postNotificationName("appExited", object: self)
		NSNotificationCenter.defaultCenter().postNotificationName("appClosed", object: nil)
		
        // Customize dialog appearance
        let pv = PopupDialogDefaultView.appearance()
        pv.titleFont    = UIFont(name: "HelveticaNeue-Light", size: 16)!
        pv.titleColor   = UIColor.whiteColor()
        pv.messageFont  = UIFont(name: "HelveticaNeue", size: 14)!
        pv.messageColor = UIColor(white: 0.8, alpha: 1)
        
        // Customize the container view appearance
        let pcv = PopupDialogContainerView.appearance()
        pcv.backgroundColor = UIColor(red:0.23, green:0.23, blue:0.27, alpha:1.00)
        pcv.cornerRadius    = 2
        pcv.shadowEnabled   = true
        pcv.shadowColor     = UIColor.blackColor()
        
        // Customize overlay appearance
        let ov = PopupDialogOverlayView.appearance()
        ov.blurEnabled = true
        ov.blurRadius  = 30
        ov.liveBlur    = true
        ov.opacity     = 0.7
        ov.color       = UIColor.blackColor()
        
        // Customize default button appearance
        let db = DefaultButton.appearance()
        db.titleFont      = UIFont(name: "HelveticaNeue-Medium", size: 14)!
        db.titleColor     = UIColor.whiteColor()
        db.buttonColor    = UIColor(red:0.25, green:0.25, blue:0.29, alpha:1.00)
        db.separatorColor = UIColor(red:0.20, green:0.20, blue:0.25, alpha:1.00)
        
        // Customize cancel button appearance
        let cb = CancelButton.appearance()
        cb.titleFont      = UIFont(name: "HelveticaNeue-Medium", size: 14)!
        cb.titleColor     = UIColor(white: 0.6, alpha: 1)
        cb.buttonColor    = UIColor(red:0.25, green:0.25, blue:0.29, alpha:1.00)
        cb.separatorColor = UIColor(red:0.20, green:0.20, blue:0.25, alpha:1.00)
		
		
		return true
	}

	func applicationWillResignActive(application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
		
		print("Application resigning active")
		Defaults[DefaultsKeys.dateAppExited._key] = NSDate()
		hasExitedAppAndGoBack = false
		
		
		NSNotificationCenter.defaultCenter().postNotificationName("appExited", object: self)

	}

	func applicationDidEnterBackground(application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(application: UIApplication) {
		// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background
	}

	func applicationDidBecomeActive(application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
		if let lastDate = Defaults["dateAppExited"].date {
//			Defaults[.timeElapsed] = Int(NSDate().timeIntervalSinceDate(lastDate))
			hasExitedAppAndGoBack = true
			NSNotificationCenter.defaultCenter().postNotificationName("didReopenApp", object: nil)
			
		}
		
		
		NSNotificationCenter.defaultCenter().postNotificationName("appEntered", object: self)

		
		
//		self.newFocusViewController.timeRemaining = self.newFocusViewController.timeRemaining - Int(timeElapsed)
//		self.newFocusViewController.updateTimer()

	}

	func applicationWillTerminate(application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
		NSNotificationCenter.defaultCenter().postNotificationName("appClosed", object: nil)

	}
	
	func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
		if notification.category == "WORKTIME_UP" {
			let foregroundNotification = BSForegroundNotification(userInfo: NotificationHelper.userInfoForCategory("WORKTIME_UP"))
			foregroundNotification.delegate = self
			foregroundNotification.timeToDismissNotification = NSTimeInterval(10)
			foregroundNotification.presentNotification()
			AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
		}
		
		else if notification.category == "BREAKTIME_UP" {
			let foregroundNotification = BSForegroundNotification(userInfo: NotificationHelper.userInfoForCategory("BREAKTIME_UP"))
			foregroundNotification.delegate = self
			foregroundNotification.timeToDismissNotification = NSTimeInterval(10)
			foregroundNotification.presentNotification()
			AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
		}
            
        else if notification.category == "START_TIMER" {
            let foregroundNotification = BSForegroundNotification(userInfo: NotificationHelper.userInfoForCategory("START_TIMER"))
            foregroundNotification.delegate = self
            foregroundNotification.timeToDismissNotification = NSTimeInterval(5)
            foregroundNotification.presentNotification()
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
        }
            
        else if notification.category == "STOP_TIMER" {
            print("Stopping timer")
        }
		
		else {
			let foregroundNotification = BSForegroundNotification(userInfo: NotificationHelper.userInfoForCategory(notification.alertBody!))
			foregroundNotification.delegate = self
			foregroundNotification.timeToDismissNotification = NSTimeInterval(86400)
			foregroundNotification.presentNotification()
			print("Presenting notification")
			AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)

		}
	}
}

