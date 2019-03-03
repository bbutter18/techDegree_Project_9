//
//  DataSource.swift
//  iOS Proximity Reminders App
//
//  Created by Woodchuck on 2/21/19.
//  Copyright © 2019 Treehouse Island. All rights reserved.
//

import UIKit
import CoreData

class DataSource: NSObject, UITableViewDataSource {
    private let tableView: UITableView
    var managedObjectContext: NSManagedObjectContext
    var locationManager: LocationManager
    
    lazy var fetchedResultsController: ReminderFetchedResultsController = {
        return ReminderFetchedResultsController(managedObjectContext: self.managedObjectContext, tableView: self.tableView)
    }()
    
    init(tableView: UITableView, context: NSManagedObjectContext, manager: LocationManager) {
        self.tableView = tableView
        self.managedObjectContext = context
        self.locationManager = manager
    }
    
    func object(at indexPath: IndexPath) -> Reminder {
        return fetchedResultsController.object(at: indexPath)
    }
    
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = fetchedResultsController.sections?[section] else {
            return 0
        }
        return section.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReminderCell") as! ReminderCell
        
        return configureCell(cell, at: indexPath)
    }
    
    
    private func configureCell(_ cell: ReminderCell, at indexPath: IndexPath) -> UITableViewCell {
        
        let item = fetchedResultsController.object(at: indexPath)
        cell.reminderTextDetailsLabel.text = item.textDetails
        cell.locationTitleLabel.text = item.locationTitle
        cell.timeStampLabel.text = item.timeStamp
        
        if item.isActive == true {
            cell.reminderCompletionIcon.image = UIImage(named: "icn_bad")
        }
        
        if item.isActive == false {
            cell.reminderCompletionIcon.image = UIImage(named: "icn_happy")
        }
        
        
        return cell
    }
    
    
    
    
    
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let item = fetchedResultsController.object(at: indexPath)
        locationManager.stopGeoFencing(latitude: item.latitude, longitude: item.longitude, locationName: item.locationTitle)
        
        managedObjectContext.delete(item)
        managedObjectContext.saveChanges()
    }
    
}
