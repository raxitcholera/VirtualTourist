//
//  client.swift
//  VirtualTourist
//
//  Created by Raxit Cholera on 6/26/17.
//  Copyright © 2017 Raxit Cholera. All rights reserved.
//

import UIKit
import CoreLocation

protocol SessionDownloadDelegate
{
    func resourceDownloaded(status: URLSessionTask.State, resourceData: Data?, error: Error?) -> Void
}


class client: NSObject, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate, URLSessionDownloadDelegate{
    
    // MARK: Properties
    
    static let sharedInstance = client()
    // shared session
    var session = URLSession.shared
    private var dataTask = URLSession()
    private var bgSession = URLSession()
    
    // authentication state
    var requestToken: String? = nil
    var sessionID: String? = nil
    var userID: Int? = nil
    
    // MARK: Initializers
    
    override init() {
        super.init()
        setupBgSession()
    }
    //MARK: Config session
    func setupBgSession() {
        
        let bgConfiguration = URLSessionConfiguration.background(withIdentifier: "bg.session.id")
        bgConfiguration.allowsCellularAccess = true
        bgConfiguration.timeoutIntervalForRequest = 60
        bgConfiguration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
    
        bgSession = URLSession(configuration: bgConfiguration, delegate: self, delegateQueue:OperationQueue())
        bgSession.sessionDescription = "session.bg"
    }
    func fetchImagesFromFlicker(location: CLLocationCoordinate2D, ofPage page:Int, apiCompletionHandler: @escaping ResutOrError)
    {
        let parameters = [
            Constants.FlickrParameterKeys.Method:Constants.FlickrParameterValues.SearchMethod,
            Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
            Constants.FlickrParameterKeys.BoundingBox: bboxString(latitude: location.latitude, longitude: location.longitude),
            Constants.FlickrParameterKeys.SafeSearch: Constants.FlickrParameterValues.UseSafeSearch,
            Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
            Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
            Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback,
            Constants.FlickrParameterKeys.Page:"\(page)",
            Constants.FlickrParameterKeys.PerPage:"21"
        ]
        getDataFromURL(url: URLFromParameters(parameters as [String:AnyObject])){ (responseData, error) in
            if error != nil {
                apiCompletionHandler(nil,error)
                return
            }else {
                let parsedResult = responseData as! [String:Any]
                
                guard let stat = parsedResult[Constants.FlickrResponseKeys.Status] as? String, stat == Constants.FlickrResponseValues.OKStatus else {
                    print("Flickr API returned an error. See error code and message in \(parsedResult)")
                    apiCompletionHandler( nil, error)
                    return
                }
                
                guard let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject] else {
                    print("Cannot find keys '\(Constants.FlickrResponseKeys.Photos)' in \(parsedResult)")
                    apiCompletionHandler(nil, error)
                    return
                }
                
                apiCompletionHandler(photosDictionary[Constants.FlickrResponseKeys.Photo], error)
            }
        }
        
    }
    
    
    
    
    
    
    
    
    
    
    
    func downloadPhotos(forList photosList: [[String:Any]])
    {
        for i in 0 ..< photosList.count
        {
            let url = URL(string:photosList[i]["url_m"] as! String)
            if(url != nil)
            {
                downloadResource(fromUrl: url!, atLocation: nil)
            }
        }
    }
    internal func downloadResource(fromUrl url: URL, atLocation location: String?)
    {
        let task = bgSession.downloadTask(with: url)
        if(location == nil){
            task.taskDescription = "newImage"
        }
        else{
            task.taskDescription = location
        }
        task.resume()
        
    }


    
    
    
    
   
    func getDataFromURL(url: URL?, apiCompletionHandler: @escaping ResutOrError)
    {
        let request = generateRequestOf(type: "GET", url: url)
        processTask(request as URLRequest, applyOffset:false, completionHandlerForProcessingTask: apiCompletionHandler)
    }
    
    
    //MARK: - Get Method
    func taskForGETMethod(_ method: String, parameters: [String:AnyObject], completionHandlerForGET: @escaping ResutOrError) {
        
        let request = generateRequestOf(type: "GET", url: URLFromParameters(parameters,withPathExtension: method))
        processTask(request as URLRequest, applyOffset:false, completionHandlerForProcessingTask: completionHandlerForGET)
        
    }
    //MARK: - Post Method
    func taskForPOSTMethod(_ method: String, parameters: [String:AnyObject], jsonBody: String, completionHandlerForPOST: @escaping ResutOrError) {
//        let tempParameter = [String:AnyObject]() //if no parameters are expected
        let request = generateRequestOf(type: "POST", url: URLFromParameters(parameters, withPathExtension: method))
        request.httpBody = jsonBody.data(using: String.Encoding.utf8)
        
        processTask(request as URLRequest, applyOffset:false, completionHandlerForProcessingTask: completionHandlerForPOST)
        
    }
    //MARK: - Put Method
    func taskForPUTMethod(_ method: String, parameters: [String:AnyObject], jsonBody: String, completionHandlerForPOST: @escaping ResutOrError) {
        //        let tempParameter = [String:AnyObject]() //if no parameters are expected
        let request = generateRequestOf(type: "PUT", url: URLFromParameters(parameters, withPathExtension: method))
        request.httpBody = jsonBody.data(using: String.Encoding.utf8)
        processTask(request as URLRequest, applyOffset:false, completionHandlerForProcessingTask: completionHandlerForPOST)
        
    }
    
    private func processTask(_ request: URLRequest, applyOffset:Bool,  completionHandlerForProcessingTask: @escaping ResutOrError)
    {
        print(request.url!)
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForProcessingTask(nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            guard (error == nil) else {
                sendError("There was an error with your request: \(String(describing: error?.localizedDescription))")
                return
            }
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("There was an Error response from the Server")
                return
            }
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            self.convertDataWithCompletionHandler(data, applyOffset: applyOffset, completionHandlerForConvertData: completionHandlerForProcessingTask)
        }
        task.resume()
        
    }
    private func convertDataWithCompletionHandler(_ data: Data, applyOffset:Bool, completionHandlerForConvertData: ResutOrError) {
        
        var parsedResult: AnyObject! = nil
        do {
            var parsedString = String.init(data: data, encoding: String.Encoding.utf8)
            
            if(applyOffset)
            {
                let startIndex = parsedString?.index((parsedString?.startIndex)!, offsetBy: 5)
                parsedString = parsedString?.substring(from: startIndex!)
            }
            
            let jsonData = parsedString?.data(using: String.Encoding.utf8)
            
            parsedResult = try JSONSerialization.jsonObject(with: jsonData!, options: [.allowFragments,.mutableContainers,.mutableLeaves]) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(parsedResult, nil)
    }
    
    private func URLFromParameters(_ parameters: [String:AnyObject], withPathExtension: String? = nil) -> URL {
        
        var components = URLComponents()
        
        components.scheme = Constants.Flickr.APIScheme
        components.host = Constants.Flickr.APIHost
        components.path = Constants.Flickr.APIPath + (withPathExtension ?? "")
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    func stringFromParam (_ parameters:[String:AnyObject])-> String {
        var outputString = String()
        
        for(key,value) in parameters{
            var value1 = String()
            
            if key == "longitude" || key == "latitude" {
                value1 = String(describing: value)
            } else {
                value1 = "\"\(value)\""
            }
            
            if (outputString.isEmpty){
                
                outputString = "\"\(key)\":\(value1)"
            } else {
                outputString = "\(String(describing: outputString)),\"\(key)\":\(value1)"
            }
        }
        
        return outputString
    }
    private func bboxString(latitude: Double, longitude: Double) -> String
    {
        let minimumLon = max(longitude - Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.0)
        let minimumLat = max(latitude - Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.0)
        let maximumLon = min(longitude + Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.1)
        let maximumLat = min(latitude + Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.1)
        return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL)
    {
        let data = FileManager.default.contents(atPath: location.relativePath)
        CoreDataManager.sharedManager.resourceDownloaded(status: downloadTask.state, resourceData: data, error: downloadTask.error)
    }
}
