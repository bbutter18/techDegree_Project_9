//
//  AddReminderController.swift
//  iOS Proximity Reminders App
//
//  Created by Woodchuck on 2/21/19.
//  Copyright © 2019 Treehouse Island. All rights reserved.
//

import UIKit
import CoreData
import MapKit
import CoreLocation

class AddReminderController: UIViewController, UISearchBarDelegate {
    
    var managedObjectContext: NSManagedObjectContext!
    var locationManager: LocationManager!
    var masterViewController: MasterViewController!
    
    
    @IBOutlet weak var reminderDetailsTextField: UITextField!
    
    
    @IBOutlet weak var toggleSwitch: UISwitch!
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    @IBOutlet weak var reminderAddressLabel: UILabel!
    
    
    var reminderLatitude: Double?
    var reminderLongitude: Double?
    var reminderLocationName: String?
    var exitRegionNotificationType: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        guard let userLocation = locationManager.currentLocation else { return }
        
        adjustMap(with: mapView, location: userLocation)
        
        
    }
    
    
    
    @IBAction func searchLocationButton(_ sender: Any) {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        present(searchController, animated: true, completion: nil)
    }
    
    
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        UIApplication.shared.beginIgnoringInteractionEvents()

        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)

        // search request
        let searchRequest = MKLocalSearchRequest()
        searchRequest.naturalLanguageQuery = searchBar.text

        let activeSearch = MKLocalSearch(request: searchRequest)

        activeSearch.start { (response, error) in
            UIApplication.shared.endIgnoringInteractionEvents()

            if response == nil {
                print("ERROR")
            } else {
                let annotations = self.mapView.annotations
                let overlays = self.mapView.overlays
                self.mapView.removeAnnotations(annotations)
                self.mapView.removeOverlays(overlays)

                guard let latitude = response?.boundingRegion.center.latitude, let longitude = response?.boundingRegion.center.longitude else { return }
                
                self.reminderLatitude = latitude
                self.reminderLongitude = longitude
                self.reminderLocationName = searchBar.text

                let annotation = MKPointAnnotation()
                annotation.title = searchBar.text
                annotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
                self.mapView.addAnnotation(annotation)

                let coordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
                let span = MKCoordinateSpanMake(0.005, 0.005)
                let region = MKCoordinateRegion(center: coordinate, span: span)
                self.mapView.setRegion(region, animated: true)
                
                let circle = MKCircle(center: coordinate, radius: self.locationManager.radius)
                self.mapView.add(circle)
                
                self.convertCoordinatesToString(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
            }
        }

    }
    
    
    func convertCoordinatesToString(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        
        let location = CLLocation.init(latitude: latitude, longitude: longitude)
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemark, error) in
            if let placemark = placemark {
                var stringLocation = ""
                let info = placemark[0]
                if let address = info.thoroughfare, let postalCode = info.postalCode, let numbers = info.subThoroughfare, let city = info.locality, let state = info.administrativeArea {
                    
                    stringLocation = "\(numbers) \(address) \n \(city), \(state) \(postalCode)"
                    
                    self.reminderAddressLabel.text = stringLocation
                }
            }
            
            
        }
        
    }
    
    
    
    
    @IBAction func saveReminderButton(_ sender: Any) {
        
        guard let reminder = NSEntityDescription.insertNewObject(forEntityName: "Reminder", into: managedObjectContext) as? Reminder else {
            return
        }
        
        guard let text = reminderDetailsTextField.text else {
            return
        }
        
        if text.isEmpty == true {
            reminderDetailsTextField.text = "** no notes **"
        }
        
        guard let reminderLatitude = reminderLatitude, let reminderLongitude = reminderLongitude, let reminderLocationName = reminderLocationName else {
            return
        }
        
        guard let streetAddressText = reminderAddressLabel.text else { return }
        
        reminder.textDetails = text
        reminder.isActive = toggleSwitch.isOn
        reminder.latitude = reminderLatitude
        reminder.longitude = reminderLongitude
        reminder.locationTitle = reminderLocationName
        reminder.timeStamp = "Created on \(Reminder.createTimeStamp())"
        reminder.streetAddress = streetAddressText
        
        if exitRegionNotificationType == false {
            reminder.exitRegion = false
        }
        
        if exitRegionNotificationType == true {
            reminder.exitRegion = true
        }
        
        if exitRegionNotificationType == nil {
            displayAlert(title: "Error", message: "Must select Notificaiton Type")
            return
        }
        
        
        if locationManager.storedMonitoredRegions() < locationManager.maxNumberOfMonitoredRegions {
            if toggleSwitch.isOn == true {
                locationManager.startGeoFencing(latitude: reminderLatitude, longitude: reminderLongitude, locationName: reminderLocationName)
            }
            
            managedObjectContext.saveChanges()
        } else {
            // show alert to user
            displayAlert(title: "Error", message: "Only 20 stored 'Reminders' locations")
        }
        
        dismiss(animated: true, completion: nil)
        
        
    }
    
    
    
    
    @IBAction func cancelReminderButton(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
        
        
    }
    
    
    func displayAlert(title: String, message: String) {
        let alert  = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    
    
    
    @IBAction func entryRegionNotificationButton(_ sender: Any) {
        
        exitRegionNotificationType = false
        //guard masterViewController.notifyOnEntry != nil else { return }
        
        //masterViewController.notifyOnEntry = true
        
        print(exitRegionNotificationType)
        
        
    }
    
    
    
    
    @IBAction func exitRegionNotificationButton(_ sender: Any) {
        
        exitRegionNotificationType = true
        
        //guard masterViewController.notifyOnExit != nil else { return }
        //masterViewController.notifyOnExit = true
        print(exitRegionNotificationType)
        
    }
    
    
    
    
}









extension AddReminderController {
    func adjustMap(with mapView: MKMapView, location: CLLocation) {
        print("executing location adjustment")
        
        let currentLatitude = location.coordinate.latitude
        let currentLongitude = location.coordinate.longitude
        
        let coordinate2D = CLLocationCoordinate2D(latitude: currentLatitude, longitude: currentLongitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        
        let region = MKCoordinateRegion(center: coordinate2D, span: span)
        mapView.setRegion(region, animated: true)
    }
}


















