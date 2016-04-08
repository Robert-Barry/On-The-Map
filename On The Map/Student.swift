//
//  Student.swift
//  On The Map
//
//  Created by Robert Barry on 3/31/16.
//  Copyright © 2016 Robert Barry. All rights reserved.
//

import Foundation

struct Student {
    
    let uniqueKey: String! // an extra (optional) key used to uniquely identify a StudentLocation
    let firstName: String! // the first name of the student which matches their Udacity profile first name
    let lastName: String! // the last name of the student which matches their Udacity profile last name
    let mapString: String! // the location string used for geocoding the student location
    var mediaURL: String! // the URL provided by the student
    let latitude: Double! // the latitude of the student location (ranges from -90 to 90)
    let longitude: Double! // the longitude of the student location (ranges from -180 to 180)
    
    //init(mapString: String, latitude: Double, longitude: Double) {
    init(studentDict: [String: AnyObject]) {
        
        self.mapString = studentDict["mapString"] as! String
        self.latitude = studentDict["latitude"] as! Double
        self.longitude = studentDict["longitude"] as! Double

        self.uniqueKey = UdacityResources.sharedInstance().udacityId
        self.firstName = UdacityResources.sharedInstance().firstName
        self.lastName = UdacityResources.sharedInstance().lastName
        
        self.mediaURL = ""
        
    }
    
    func toString() {
        print("Unique Key: \(self.uniqueKey), First Name: \(self.firstName), Last Name: \(self.lastName), Map String: \(self.mapString), URL: \(self.mediaURL), Latitude: \(self.latitude), Longitude: \(self.longitude)")
    }

}
