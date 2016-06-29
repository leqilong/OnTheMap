//
//  AppDelegate.swift
//  OnTheMap
//
//  Created by Leqi Long on 6/16/16.
//  Copyright © 2016 Student. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let loginManager = FBSDKLoginManager()
    
    func applicationDidBecomeActive(application: UIApplication) {
        FBSDKAppEvents.activateApp()
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        FBSDKSettings.setAppURLSchemeSuffix(FacebookLogin.SchemeSuffix)
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        if url.scheme == FacebookLogin.Scheme{
            FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
        }

        return true
    }
    
    class func getDelegate() -> AppDelegate {
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }
    
    func getAccessToken() -> FBSDKAccessToken! {
        return FBSDKAccessToken.currentAccessToken()
    }
    
    
    func logout(){
        loginManager.logOut()
    }

    

}

