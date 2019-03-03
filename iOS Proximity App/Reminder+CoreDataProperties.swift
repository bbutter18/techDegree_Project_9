//
//  Reminder+CoreDataProperties.swift
//  iOS Proximity Reminders App
//
//  Created by Woodchuck on 2/21/19.
//  Copyright © 2019 Treehouse Island. All rights reserved.
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Reminder {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Reminder> {
        let request = NSFetchRequest<Reminder>(entityName: "Reminder")
        request.sortDescriptors = [NSSortDescriptor(key: "textDetails", ascending: true)]
        return request
    }

    
}

extension Reminder {
    static func createTimeStamp() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        let convertedDate = dateFormatter.string(from: Date())
        return convertedDate
    }
    
}





