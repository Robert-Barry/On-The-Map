//
//  AppDelegate.swift
//  On The Map
//
//  Created by Robert Barry on 2/17/16.
//  Copyright © 2016 Robert Barry. All rights reserved.
//

import UIKit

@objc
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    // The Reachability code is based on the tutorial from https://www.youtube.com/watch?v=BlBhHgoW9wM
    //
    let kREACHABLEVIAWIFI = "ReachableViaWiFi"
    let kNOTREACHABLE = "NotReachable"
    let kREACHABLEVIAWWAN = "ReachableViaWWAN"
    
    var reachability: Reachability?
    var internetReach: Reachability?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        // Watch for the internet connection to change
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AppDelegate.reachabilityChanged(_:)), name: kReachabilityChangedNotification, object: nil)
        
        // Start the notification
        internetReach = Reachability.reachabilityForInternetConnection()
        internetReach?.startNotifier()
        
        if internetReach != nil {
            statusChangedWithReachability(internetReach!)
        }
        
        return true
    }
    
    func statusChangedWithReachability(currentReachabilityStatus: Reachability) {
        
        var networkStatus: NetworkStatus = currentReachabilityStatus.currentReachabilityStatus()
        
        print("StatusValue: \(networkStatus.rawValue)")
        
        // if the network connection changes, save the result in UdacityResources
        if networkStatus.rawValue == NotReachable.rawValue {
            print("Network Not Reachable...")
            UdacityResources.sharedInstance().reachable = false
        } else {
            print("Network Reachable.")
            UdacityResources.sharedInstance().reachable = true
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName("ReachStatusChanged", object: nil)
        
    }
    
    func reachabilityChanged(notification: NSNotification) {
        print("Reachability Status Changed...")
        reachability = notification.object as? Reachability
        self.statusChangedWithReachability(reachability!)
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        NSNotificationCenter.defaultCenter().removeObserver(self, name: kReachabilityChangedNotification, object: nil)
    }


}

