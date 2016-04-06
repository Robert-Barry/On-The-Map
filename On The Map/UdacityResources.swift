//
//  UdacityResources.swift
//  On The Map
//
//  Created by Robert Barry on 3/24/16.
//  Copyright © 2016 Robert Barry. All rights reserved.
//
// Class to create a singleton for data that will be used throughout the application

import Foundation

class UdacityResources {
    
    // Session ID retrieved from Udacity
    var sessionId: String? = nil
    var udacityId: String? = nil
    var firstName: String? = nil
    var lastName: String? = nil
    var method: String? = "POST"
    var objectId: String? = nil
    var studentInformationArray: [StudentInformation]? = nil
    
    // Create a singleton
    class func sharedInstance() -> UdacityResources {
        struct Singleton {
            static var sharedInstance = UdacityResources()
        }
        return Singleton.sharedInstance
    }
}