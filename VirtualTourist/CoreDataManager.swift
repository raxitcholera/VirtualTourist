//
//  CoreDataManager.swift
//  VirtualTourist
//
//  Created by Raxit Cholera on 6/26/17.
//  Copyright © 2017 Raxit Cholera. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

protocol CoreDataManagerDelegate: NSObjectProtocol
{
    func refreshView()
}

class CoreDataManager: NSObject, SessionDownloadDelegate {

    static let sharedManager = CoreDataManager()
    var location: Location!
    weak var delegate: CoreDataManagerDelegate?
    
    override private init()
    {
        super.init()
    }
    
    func addLocation(coordinate: CLLocationCoordinate2D) -> Location
    {
        let loc = Location(coordinate: coordinate, context: appDelegate.stack.context)
        dbStack.save()
        
        return loc
    }
    
    
    //MARK:- SessionDownloadDelegate Method
    
    func resourceDownloaded(status: URLSessionTask.State, resourceData: Data?, error: Error?)
    {
        guard error == nil else {
            
            print("Error while downloading resource: \(String(describing: error?.localizedDescription))")
            return
        }
        
        if (status == .completed || status == .running)
        {
            if let data = resourceData
            {
                let image = Image(imageData: NSData(data:data), context: appDelegate.stack.context)
                location.addToImages(image)
                dbStack.save()
                delegate?.refreshView()
            }
        }
    }
}
