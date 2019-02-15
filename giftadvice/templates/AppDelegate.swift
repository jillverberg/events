//
//  AppDelegate.swift
//  <%= @project %>
//
//  Created by <%= @author %> on <%= @date %>.
//  Copyright © 2018 ForaSoft. All rights reserved.
//

import UIKit
import HockeySDK_Source

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // MARK: Public Properties

    var window: UIWindow?

    // MARK: Private Properties
    
    private var launchRouter: LaunchRouter?
    
    // MARK: UIApplicationDelegate
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        setupAppearance()
        setupFrameworks()
        setupLaunchScreen()
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        // TODO: Setup your orientation modes
        return UIInterfaceOrientationMask.portrait
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // TODO: Use this method for reduse badge number if notification was enabled
        // For example:
            // UIApplication.shared.applicationIconBadgeNumber = 0
            // UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
    }
    
    // MARK: Private Methods
    
    // Setup application appearence
    private func setupAppearance() {
        // For example:
            // UIApplication.shared.keyWindow?.backgroundColor = UIColor.white
    }
    
    // Setup your frameworks
    private func setupFrameworks() {
        // Requied for all projects
        if let hockeyAppApplicationIdentifier = InfoPlistService.shared.hockeyAppApplicationIdentifier(), !hockeyAppApplicationIdentifier.isEmpty {
            BITHockeyManager.shared().configure(withIdentifier: hockeyAppApplicationIdentifier)
            BITHockeyManager.shared().start()
        }
        
        // For example:
            // IQKeyboardManager.sharedManager().enable = true
    }
    
    // Setup Launch Screen from LaunchRouter
    private func setupLaunchScreen() {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.makeKeyAndVisible()
        
        let launchRouter = LaunchRouter(withWindow: window)
        
        self.window = window
        self.launchRouter = launchRouter
    }
}
