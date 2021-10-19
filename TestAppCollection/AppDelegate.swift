//
//  AppDelegate.swift
//  TestAppCollection
//
//  Created by Artem Farafonov on 15.10.2021.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    private var resourceManager: ResourceManager?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        self.resourceManager = ResourceManager()
        
        return true
    }

}

