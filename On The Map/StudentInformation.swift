//
//  StudentInformation.swift
//  On The Map
//
//  Created by Robert Barry on 4/6/16.
//  Copyright © 2016 Robert Barry. All rights reserved.
//

import Foundation
import MapKit

struct StudentInformation {
    
    var title: String
    var coordinate: CLLocationCoordinate2D
    var mediaUrl: String
    
    var annotation = MKPointAnnotation()
    
    init(studentInfoDict: [String:AnyObject]) {
        
        self.title = studentInfoDict["title"] as! String
        self.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(studentInfoDict["latitude"] as! Double), longitude: CLLocationDegrees(studentInfoDict["longitude"] as! Double))
        self.mediaUrl = studentInfoDict["mediaUrl"] as! String
        
        self.annotation.coordinate = self.coordinate
        self.annotation.title = self.title
        self.annotation.subtitle = self.mediaUrl
        
    }
    
}