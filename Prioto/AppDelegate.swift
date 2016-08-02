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
		IQKeyboardManager.sharedManager().enable = true
		IQKeyboardManager.sharedManager().shouldResignOnTouchOutside = true
		// types are UIUserNotificationType values
		application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil))

		if let tabBarController = self.window!.rootViewController as? UITabBarController {
			for viewController in tabBarController.viewControllers! {
				if let view = viewController.topViewController()  {
					view.view.description
				}
			}
		}
		
//		let tabBarController = self.window!.rootViewController as! UITabBarController
//		for viewController in tabBarController.viewControllers! {
//			let aView = viewController.topViewController as! UIViewController
//			aView.view.description
//		}
		
		
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
	}
	
	func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
		if notification.category == "WORKTIME_UP" {
			let foregroundNotification = BSForegroundNotification(userInfo: NotificationHelper.userInfoForCategory("WORKTIME_UP"))
			foregroundNotification.delegate = self
			foregroundNotification.timeToDismissNotification = NSTimeInterval(5)
			foregroundNotification.presentNotification()
		}
		
		else if notification.category == "BREAKTIME_UP" {
			let foregroundNotification = BSForegroundNotification(userInfo: NotificationHelper.userInfoForCategory("BREAKTIME_UP"))
			foregroundNotification.delegate = self
			foregroundNotification.timeToDismissNotification = NSTimeInterval(5)
			foregroundNotification.presentNotification()
		}
	}
}

