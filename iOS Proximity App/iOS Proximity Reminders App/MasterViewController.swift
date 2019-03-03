//
//  MasterViewController.swift
//  iOS Proximity Reminders App
//
//  Created by Woodchuck on 2/21/19.
//  Copyright © 2019 Treehouse Island. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import UserNotifications

class MasterViewController: UITableViewController, UNUserNotificationCenterDelegate, LocationManagerDelegate {
    
    var managedObjectContext = CoreDataStack().managedObjectContext
    var locationManager = LocationManager()
    
    var reminder: Reminder?
    
     var notifyOnExit: Bool = false
     var notifyOnEntry: Bool = false

    lazy var dataSource: DataSource = {
        return DataSource(tableView: self.tableView, context: self.managedObjectContext, manager: self.locationManager)
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        
        locationManager.delegate = self
        
        UNUserNotificationCenter.current().delegate = self
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (didAllow, error) in
            if let error = error {
                print(error)
            }
        }
        
        //displayEntryAlert(title: "Attention", message: "Would you like notifications on Entry of Reminder Region?")
        
        //displayExitAlert(title: "Attention", message: "Would you like notifications on Exit of Reminder Region?")
    
        
    }
    
    
    func setupTableView() {
        tableView.dataSource = dataSource
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120.0
        
    }
    
    
    func displayEntryAlert(title: String, message: String) {
        let alert  = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            self.notifyOnEntry = true
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
        
    }
    
    
    func displayExitAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            self.notifyOnExit = true
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    
    
    
    
    
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createReminder" {
            if let navigationController = segue.destination as? UINavigationController {
                if let addReminderController = navigationController.topViewController as? AddReminderController {
                    addReminderController.managedObjectContext = managedObjectContext
                    addReminderController.locationManager = locationManager
                }
            }
        } else if segue.identifier == "showDetail" {
            if let navigationController  = segue.destination as? UINavigationController {
                if let detailViewController = navigationController.topViewController as? DetailViewController, let indexPath = tableView.indexPathForSelectedRow {
                    let item = dataSource.object(at: indexPath)
                    detailViewController.reminder = item
                    detailViewController.managedObjectContext = managedObjectContext
                    detailViewController.locationManager = locationManager
                }
            }
        }
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
}

extension MasterViewController {
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        setupNotification(type: "REMINDER!", body: "You are entering \(region.identifier)", region: region)
        guard let regionEntry = reminder?.exitRegion else { return }
        
        region.notifyOnEntry = regionEntry
        print("entry notification is setup")
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        setupNotification(type: "REMINDER!", body: "You have removed yourself from \(region.identifier)", region: region)
        guard let regionExit = reminder?.exitRegion else { return }
        region.notifyOnExit = regionExit
        print("exit notification is setup")
    }
}



extension MasterViewController {
    
    func setupNotification(type: String, body: String, region: CLRegion) {
        let content = UNMutableNotificationContent()
        content.title = type
        content.body = body
        content.sound = UNNotificationSound.default()
        
        region.notifyOnEntry = true
        region.notifyOnExit = false
        
        if notifyOnExit == true {
            region.notifyOnExit = true
        }
        
        if notifyOnEntry == true {
            region.notifyOnEntry = true 
        }
        
        let trigger = UNLocationNotificationTrigger(region: region, repeats: false)
        
        let request = UNNotificationRequest(identifier: "Reminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print(error)
            }
        }
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
}










