//
//  clientConvinience.swift
//  VirtualTourist
//
//  Created by Raxit Cholera on 6/26/17.
//  Copyright © 2017 Raxit Cholera. All rights reserved.
//

import Foundation

extension client {
    
    func generateRequestOf(type: String!, url: URL!) -> NSMutableURLRequest
    {
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = type
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
}
