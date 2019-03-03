//
//  DetailViewController.swift
//  iOS Proximity Reminders App
//
//  Created by Woodchuck on 2/21/19.
//  Copyright © 2019 Treehouse Island. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class DetailViewController: UIViewController {
    
    var reminder: Reminder?
    var managedObjectContext: NSManagedObjectContext!
    var locationManager: LocationManager!

    
    @IBOutlet weak var mapView: MKMapView!
    
    
    @IBOutlet weak var reminderAddressLabel: UILabel!
    
    
    @IBOutlet weak var reminderDetailsEditTextField: UITextField!
    
    
    @IBOutlet weak var reminderSwitch: UISwitch!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let reminder = reminder {
           
        reminderDetailsEditTextField.text = reminder.textDetails
        reminderAddressLabel.text = reminder.streetAddress
        reminderSwitch.setOn(reminder.isActive, animated: false)
        
        let annotation = MKPointAnnotation()
        annotation.title = reminder.locationTitle
        annotation.coordinate = CLLocationCoordinate2DMake(reminder.latitude, reminder.longitude)
        self.mapView.addAnnotation(annotation)
        
        let coordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(reminder.latitude, reminder.longitude)
        let span = MKCoordinateSpanMake(0.005, 0.005)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        self.mapView.setRegion(region, animated: true)
        }
    }
    
    @IBAction func saveEditedReminderButton(_ sender: Any) {
        
        if let reminder = reminder, let newText = reminderDetailsEditTextField.text {
            reminder.textDetails = newText
            reminder.isActive = reminderSwitch.isOn
            reminder.timeStamp = "Updated on \(Reminder.createTimeStamp())"

            if reminderSwitch.isOn == false {
                locationManager.stopGeoFencing(latitude: reminder.latitude, longitude: reminder.longitude, locationName: reminder.locationTitle)
            } else if reminderSwitch.isOn == true {
                locationManager.startGeoFencing(latitude: reminder.latitude, longitude: reminder.longitude, locationName: reminder.locationTitle)
            }
            
            managedObjectContext.saveChanges()
            navigationController?.navigationController?.popViewController(animated: true)
        }
        
        
        
    }
    
    @IBAction func save(_ sender: Any) {
        if let reminder = reminder, let newText = reminderDetailsEditTextField.text {
            reminder.textDetails = newText
            reminder.isActive = reminderSwitch.isOn
            
            if reminderSwitch.isOn == false {
                locationManager.stopGeoFencing(latitude: reminder.latitude, longitude: reminder.longitude, locationName: reminder.locationTitle)
            } else if reminderSwitch.isOn == true {
                locationManager.startGeoFencing(latitude: reminder.latitude, longitude: reminder.longitude, locationName: reminder.locationTitle)
            }
            
            managedObjectContext.saveChanges()
            navigationController?.navigationController?.popViewController(animated: true)
        }
    }
    
    
    @IBAction func deleteReminderButton(_ sender: Any) {
        if let reminder = reminder {
            locationManager.stopGeoFencing(latitude: reminder.latitude, longitude: reminder.longitude, locationName: reminder.locationTitle)
            
            managedObjectContext.delete(reminder)
            managedObjectContext.saveChanges()
            navigationController?.navigationController?.popViewController(animated: true)
        }
    }
    
        
        
        
}
        
    
















