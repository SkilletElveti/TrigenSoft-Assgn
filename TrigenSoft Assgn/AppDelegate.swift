//
//  AppDelegate.swift
//  TrigenSoft Assgn
//
//  Created by Shubham Vinod Kamdi on 04/09/20.
//

import UIKit
import GoogleMaps
import GooglePlaces

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        GMSServices.provideAPIKey("AIzaSyCSGtoCmeuAwpsFiM8j79qEdVMCtGHZaDA")
        GMSPlacesClient.provideAPIKey("AIzaSyCSGtoCmeuAwpsFiM8j79qEdVMCtGHZaDA")
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
           willPresent notification: UNNotification,
           withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void){
        completionHandler(.alert)
    }

   

}

