//
//  Image+CoreDataClass.swift
//  VirtualTourist
//
//  Created by Raxit Cholera on 6/26/17.
//  Copyright © 2017 Raxit Cholera. All rights reserved.
//

import Foundation
import CoreData

@objc(Image)
public class Image: NSManagedObject {
    convenience init(imageData: NSData, context: NSManagedObjectContext)
    {
        if let ent = NSEntityDescription.entity(forEntityName: "Image", in: context)
        {
            self.init(entity: ent, insertInto: context)
            self.image = imageData
        }
            
        else
        {
            fatalError("Unable to find Entity name!")
        }
    }
}
