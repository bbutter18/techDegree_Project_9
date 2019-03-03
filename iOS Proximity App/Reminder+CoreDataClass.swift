//
//  Reminder+CoreDataClass.swift
//  iOS Proximity Reminders App
//
//  Created by Woodchuck on 2/21/19.
//  Copyright © 2019 Treehouse Island. All rights reserved.
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData

//@objc(Reminder) //remove this??

public class Reminder: NSManagedObject {

    
    @NSManaged public var textDetails: String
    @NSManaged public var isActive: Bool
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var locationTitle: String
    @NSManaged public var timeStamp: String?
    @NSManaged public var streetAddress: String?
    @NSManaged public var exitRegion: Bool
    
    
}
