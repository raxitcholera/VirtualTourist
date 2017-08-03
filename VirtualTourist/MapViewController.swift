//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by Raxit Cholera on 6/25/17.
//  Copyright © 2017 Raxit Cholera. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var editPins: Bool = false
    var existingLocations = [Location]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Virtual Tourist"
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(mapViewLongPressed(gestureRecognizer:)))
        mapView.addGestureRecognizer(longPressRecognizer)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadPins()
    }
    
    @IBAction func editPins(_ sender: Any) {
        if !editPins {
            editPins = true
            navigationItem.rightBarButtonItem?.title = "Done"
            
        } else {
            editPins = false
            navigationItem.rightBarButtonItem?.title = "Edit"
        }
    }
    
    //MARK: - Load Existing Pins
    func loadPins(){
        
        let annotations = mapView.annotations
        mapView.removeAnnotations(annotations)
        
        do {
            existingLocations = try appDelegate.stack.context.fetch(Location.fetchRequest()) as! [Location]
            
            if(existingLocations.count > 0)
            {
                for location in existingLocations
                {
                    if(location.entity.name == "Location")
                    {
                        dropAnnotation(location: location)
                    }
                }
            }
        }
            
        catch {
            print("Error while fetching entity 'Location': \(error.localizedDescription)")
        }

    }
    
    //MARK: - Dropping a pin
    func dropAnnotation(location: Location)
    {
        let annotation = MyCustomAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        annotation.title = ""
        annotation.subtitle = ""
        annotation.location = location
        mapView.addAnnotation(annotation)
    }
    
    //MARK: - Action related to add Pin
    func mapViewLongPressed(gestureRecognizer: UILongPressGestureRecognizer)
    {
        if(gestureRecognizer.state == .began)
        {
            let touchLocation: CGPoint = gestureRecognizer.location(in: mapView);
            let coordinate = mapView.convert(touchLocation, toCoordinateFrom: mapView)
            let loc = CoreDataManager.sharedManager.addLocation(coordinate: coordinate)
            dropAnnotation(location: loc)
        }
        
    }
    //MARK: - Actions related to Pin Selected
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        let annotation = view.annotation as! MyCustomAnnotation
        pinTapped(annotation: annotation)
        
    }
    func pinTapped(annotation:MyCustomAnnotation){
     
        if let loc = annotation.location
        {
            if(editPins == false)
            {
                let imagesVC = storyboard?.instantiateViewController(withIdentifier: "imagesVC") as! ImagesCollectionViewController
                imagesVC.selectedLocation = loc
                CoreDataManager.sharedManager.location = loc
                navigationController?.pushViewController(imagesVC, animated: true)
            }
                
            else
            {
                showBooleanAlert(title: "Are you sure you want to delete this location?", message: "", viewcontroller: self, completionHandler: { (answer) in
                    
                    if answer
                    {
                        self.dbStack.context.delete(loc)
                        self.mapView.removeAnnotation(annotation)
                        self.dbStack.save()
                    }
                })
                
            }
        }
    }

   
}
