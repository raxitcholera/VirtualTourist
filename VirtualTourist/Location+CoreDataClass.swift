//
//  Location+CoreDataClass.swift
//  VirtualTourist
//
//  Created by Raxit Cholera on 6/26/17.
//  Copyright © 2017 Raxit Cholera. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation

@objc(Location)
public class Location: NSManagedObject {
    convenience init(coordinate: CLLocationCoordinate2D, context: NSManagedObjectContext)
    {
        if let ent = NSEntityDescription.entity(forEntityName: "Location", in: context)
        {
            self.init(entity: ent, insertInto: context)
            self.latitude = coordinate.latitude
            self.longitude = coordinate.longitude
        }
            
        else
        {
            fatalError("Unable to find Entity name!")
        }
    }
}
