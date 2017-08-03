//
//  ImagesCollectionViewController.swift
//  VirtualTourist
//
//  Created by Raxit Cholera on 6/25/17.
//  Copyright © 2017 Raxit Cholera. All rights reserved.
//

import UIKit
import MapKit
import CoreData

private let reuseIdentifier = "pinImage"

class ImagesCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, CoreDataManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    var selectedLocation:Location!
    private var imagesArray: [Image]!
    private var deleteImagesArray:[Image]!
    private var downloadImagesArray = [[String:Any]]()
    
    var pageNo:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagesArray = selectedLocation.images?.allObjects as? [Image] ?? [Image]()
        dropPinLocation()
        
        CoreDataManager.sharedManager.delegate = self
        
        if(selectedLocation.images?.allObjects.count == 0)
        {
            getImagefromFlicker()
        }
        
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return downloadImagesArray.count > 0 ? downloadImagesArray.count : selectedLocation.images?.allObjects.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! pinImageCollectionViewCell
        
        if(imagesArray.count > indexPath.row){
            let image = UIImage(data: imagesArray[indexPath.row].image! as Data)
            cell.bindCell(image: image)
        } else {
            cell.bindCell(image: nil)
        }
        
        // Configure the cell
    
        return cell
    }
    
    func refreshView()
    {
        imagesArray = selectedLocation.images?.allObjects as! [Image]
        performOnMainthread {
            self.imageCollectionView.reloadData()
        }
    }
    
    func getImagefromFlicker(){
        
        let cordinates = CLLocationCoordinate2D(latitude: selectedLocation.latitude, longitude: selectedLocation.longitude)
        
        
        client.sharedInstance.fetchImagesFromFlicker(location: cordinates, ofPage: pageNo) { (result, error) in
            
            if error != nil {
                showAlertwith(title: "Error Fetching Images", message: "Flicker may have responded unexpectely", vc: self)
            } else {
                self.downloadImagesArray = result as! [[String:Any]]
                
                self.refreshView()
                self.downloadPhotos()
            }
        }
    }
    private func downloadPhotos()
    {
        CoreDataManager.sharedManager.location = selectedLocation
        client.sharedInstance.downloadPhotos(forList: downloadImagesArray)
    }
    
    func dropPinLocation() {
        startNetworkinUseIndicator()
        
            let pointAnnotation = MKPointAnnotation()
            pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: selectedLocation.latitude, longitude:     selectedLocation.longitude)
            let pinAnnotationView = MKPinAnnotationView(annotation: pointAnnotation, reuseIdentifier: nil)
            self.mapView.centerCoordinate = pointAnnotation.coordinate
            self.mapView.setRegion(MKCoordinateRegionMakeWithDistance(pointAnnotation.coordinate, 2000, 2000), animated: true)
            self.mapView.addAnnotation(pinAnnotationView.annotation!)
            
            stopNetworkinUseIndicator()
        
    }
    
    @IBAction func NewCollectionClicked(_ sender: Any) {
        pageNo += 1
        
        deleteImagesArray = selectedLocation.images?.allObjects as? [Image]
        for i in 0 ..< deleteImagesArray.count
        {
//            selectedLocation.removeFromImages(deleteImagesArray[i])
            dbStack.context.delete(deleteImagesArray[i])
            dbStack.save()
        }
        refreshView()
        getImagefromFlicker()
    }
    
    func removeThisImage(image:Image){
        
        deleteImagesArray.append(image)
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        dbStack.context.delete(imagesArray[indexPath.row])
        refreshView()
    }

}
