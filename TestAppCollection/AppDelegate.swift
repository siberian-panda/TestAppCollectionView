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
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(_selector),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
        
        return true
    }
    
    @objc private func _selector(_ notification: Notification) {
        guard self.resourceManager == nil else {
            return
        }
        if let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController,
           let rootViewController = navigationController.viewControllers.first as? ViewController {
            self.resourceManager = ResourceManager.init(with: rootViewController)
        }
    }

}

