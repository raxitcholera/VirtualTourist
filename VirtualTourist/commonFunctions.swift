//
//  commonFunctions.swift
//  VirtualTourist
//
//  Created by Raxit Cholera on 6/25/17.
//  Copyright © 2017 Raxit Cholera. All rights reserved.
//


import Foundation
import UIKit

public typealias ObjectHandler = (Any?) -> Void
public typealias DownloadTaskHandler = (Bool,Error?) -> Void
public typealias APICompletionHandler = (Bool, Any?, Error?) -> Void
public typealias ResutOrError = (Any? ,Error?) -> Void

func startNetworkinUseIndicator()
{
    UIApplication.shared.isNetworkActivityIndicatorVisible = true
}

func stopNetworkinUseIndicator()
{
    UIApplication.shared.isNetworkActivityIndicatorVisible = false
}

func performOnMainthread(updates: @escaping () -> Void) {
    DispatchQueue.main.async{
        updates()
    }
}

func performInBackgroundthread(tasks: @escaping () -> Void) {
    DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
        tasks()
    }
}

func showBooleanAlert(title: String?, message: String?, viewcontroller: UIViewController!, completionHandler handler: @escaping (Bool) -> Void)
{
    let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
    
    let actionYes = UIAlertAction(title: "Update", style: .default, handler: { action in
        handler(true)
    })
    
    let actionNo = UIAlertAction(title: "Cancel", style: .default, handler: { action in
        handler(false)
    })
    
    alertView.addAction(actionYes)
    alertView.addAction(actionNo)
    
    viewcontroller.present(alertView, animated: true, completion: nil)
}

func showAlertwith(title: String?, message: String?, vc: UIViewController!)
{
    let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let alertAction = UIAlertAction(title: "OK", style: .default, handler: { action in
    })
    
    alertView.addAction(alertAction)
    performOnMainthread {
        vc.present(alertView, animated: true, completion: nil)
    }
}
