//
//  AppDelegate.swift
//  InteractiveNotifications
//
//  Created by ESS Mac Pro on 4/4/17.
//  Copyright © 2017 NGA Group Inc. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,UNUserNotificationCenterDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound]) { (authorized:Bool, error:Error?) in
            if !authorized{
                print("App is useless because you did not allow notifications.")
            }
        }
        
        //Define Actions
        let fruitAction = UNNotificationAction(identifier: "addFruit", title: "Add a piece of fruit", options: [])
        let veggiAction = UNNotificationAction(identifier: "addVegetable", title: "Add a piece of vegetable", options: [])
        
        //Add action to a foodcategory
        let category = UNNotificationCategory(identifier: "foodCategory", actions: [fruitAction,veggiAction], intentIdentifiers: [], options: [])
        
        //Add the foodCategory to Notification framework
        UNUserNotificationCenter.current().setNotificationCategories([category])
        
        return true
    }

    func scheduleNotification() {
        
        UNUserNotificationCenter.current().delegate = self
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        let content = UNMutableNotificationContent()
        content.title = "Stay Healthy"
        content.body = "Just a reminder to eat your favorite healthy food."
        content.sound = UNNotificationSound.default()
        content.categoryIdentifier = "foodCategory"
        
        guard let path = Bundle.main.path(forResource: "", ofType: "png") else {return}
        
        let url = URL(fileURLWithPath: path)
        
        do{
            let attachment = try UNNotificationAttachment(identifier: "logo", url: url, options: nil)
            content.attachments = [attachment]
        }catch{
            print("The attachment could not be loaded")
        }
        
        let request = UNNotificationRequest(identifier: "foodNotification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().add(request) { (error:Error?) in
            if let error = error{
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let foodItem = Food(context: persistentContainer.viewContext)
        foodItem.added = NSDate()
        
        if response.actionIdentifier == "addFruit" {
            foodItem.type = "Fruit"
        }else{
            foodItem.type = "Vegetable"
        }
        
        self.saveContext()
        scheduleNotification()
        
        completionHandler()
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "InteractiveNotifications")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

