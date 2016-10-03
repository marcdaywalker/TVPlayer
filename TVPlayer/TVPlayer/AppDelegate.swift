//
//  AppDelegate.swift
//  TVPlayer
//
//  Created by Madriz on 7/9/16.
//  Copyright © 2016 MMApps. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        window = UIWindow(frame: UIScreen.main.bounds)
        if let window = window {
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let viewController = storyboard.instantiateViewController(withIdentifier: "MainViewController") as? ViewController {
                let item = Item(itemId: 1, itemContentPk: nil, itemDesc: "", itemTitle: "Antena 3", itemType: .channel, itemImageURL: nil, itemSubcategories: nil)
                viewController.items = [item]
                window.rootViewController = viewController
                window.makeKeyAndVisible()
            }
        }
        return true
    }
    
}

