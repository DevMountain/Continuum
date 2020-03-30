//
//  AppDelegate.swift
//  Continuum
//
//  Created by Maxwell Poffenbarger on 2/4/20.
//  Copyright © 2020 Max Poff. All rights reserved.
//

import UIKit
import CloudKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        checkAccountStatus { (success) in
            
            let fetchedUserStatment = success ? "Successfully retrieved a logged in user" : "Failed to retrieve a logged in user"
            
            print(fetchedUserStatment)
        }
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (success, error) in
            
            if let error = error {
                print("There was an error in \(#function) ; \(error)  ; \(error.localizedDescription)")
                return
            }
            success ? print("Successfully authorized to send push notfiication") : print("DENIED, Can't send this person notificiation")
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
        return true
    }
    
    func checkAccountStatus(completion: @escaping (Bool) -> Void) {
        
        CKContainer.default().accountStatus { (status, error) in
            
            if let error = error {
                print("Error checking accountStatus \(error) \(error.localizedDescription)")
                return completion(false)
            }
            else {
                DispatchQueue.main.async {
                    
                    let tabBarController = self.window?.rootViewController
                    
                    let errrorText = "Sign into iCloud in Settings"
                    
                    switch status {
                    case .available:
                        completion(true);
                        
                    case .noAccount:
                        tabBarController?.presentSimpleAlertWith(title: errrorText, message: "No account found")
                        completion(false)
                        
                    case .couldNotDetermine:
                        tabBarController?.presentSimpleAlertWith(title: errrorText, message: "There was an unknown error fetching your iCloud Account")
                        completion(false)
                        
                    case .restricted:
                        tabBarController?.presentSimpleAlertWith(title: errrorText, message: "Your iCloud account is restricted")
                        completion(false)
                        
                    default:
                        tabBarController?.presentSimpleAlertWith(title: errrorText, message: "Unknown Error")
                    }
                }
            }
        }
    }
}//End of class

