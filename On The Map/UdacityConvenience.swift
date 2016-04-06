//
//  UdacityConvenience.swift
//  On The Map
//
//  Created by Robert Barry on 4/6/16.
//  Copyright © 2016 Robert Barry. All rights reserved.
//

import Foundation
import MapKit

extension UdacityClient {
    
    // MARK: Login functions
    
    // Begin the authentication process
    func authenticate(jsonBody: String, completionHandlerForAuth: (success: Bool, errorString: String?) -> Void) {
        
        print("Authenticating...")
        
        // Begin completion handler chain for the authentication process
        getSessionAndUdacityIds(jsonBody) { (success, sessionId, udacityId, errorString) in
            
            if success {
                
                // Save the session ID and Udacity ID
                UdacityResources.sharedInstance().sessionId = sessionId
                UdacityResources.sharedInstance().udacityId = udacityId
                
                // Get the user name
                self.getUserName() { success, firstName, lastName, errorString in
                    
                    if success {
                        
                        // Save the user's first and last name
                        UdacityResources.sharedInstance().firstName = firstName
                        UdacityResources.sharedInstance().lastName = lastName
                        
                    }
                    completionHandlerForAuth(success: success, errorString: errorString)
                }
            } else {
                completionHandlerForAuth(success: success, errorString: errorString)
            }
        }
    }
    
    // Login using Udacity credentials
    private func getSessionAndUdacityIds(jsonBody: String, completionHandlerForIds: (success: Bool, sessionId: String?, udacityId: String?, errorString: String?) -> Void) {
        
        print("Getting session and Udacity IDs")
        
        // Creat empty parameters
        let parameters = [String: AnyObject]()
        
        // POST to get the session ID and Udacity ID in 1 request
        taskForPOSTMethod(UdacityConstants.UdacityApi, method: UdacityConstants.UdacitySession, parameters: parameters, jsonBody: jsonBody) { results, error in

            if let error = error {
                
                print(error)

                completionHandlerForIds(success: false, sessionId: nil, udacityId: nil, errorString: "Wrong email and/or password. Please try again.")
                
            } else {
                
                // Chain of unwrapping optionals from the results
                if let accountDict = results["account"] as? [String:AnyObject] {
                    if let udacityId = accountDict["key"] as? String {
                        if let sessionDict = results["session"] as? [String:AnyObject] {
                            if let sessionId = sessionDict["id"] as? String {
                                // If the unwrapping chain is successful, end the chain
                                completionHandlerForIds(success: true, sessionId: sessionId, udacityId: udacityId, errorString: nil)
                            } else {
                                completionHandlerForIds(success: false, sessionId: nil, udacityId: nil, errorString: "There was a problem retrieving your account information. Please try again.")
                                print("There was an error unwrapping ID")
                            }
                        } else {
                            completionHandlerForIds(success: false, sessionId: nil, udacityId: nil, errorString: "There was a problem retrieving your account information. Please try again.")
                            print("There was an error unwrapping session.")
                        }
                    } else {
                        completionHandlerForIds(success: false, sessionId: nil, udacityId: nil, errorString: "There was a problem retrieving your account information. Please try again.")
                        print("There was an error unwrapping key.")
                    }
                } else {
                    completionHandlerForIds(success: false, sessionId: nil, udacityId: nil, errorString: "There was a problem retrieving your account information. Please try again.")
                    print("There was an error unwrapping results.")
                }
                
            }
            
        }}
    
    // Get the first and last name of the Udacity user
    private func getUserName(completionHandlerForUserName: (success: Bool, firstName: String?, lastName: String?, errorString: String?) -> Void) {
        
        print("Getting user name")
        
        // Creat empty parameters
        let parameters = [String: AnyObject]()
        
        // Unwrap the Udacity ID to use in the taskForGETMethod method argument
        guard let udacityId = UdacityResources.sharedInstance().udacityId else {
            print("Error getting user ID")
            return
        }
        
        // GET the user's first and last names
        taskForGETMethod(UdacityConstants.UdacityApi, method: (UdacityConstants.UdacityUsers + "/" + udacityId), parameters: parameters) {
            results, error in
            
            if let error = error {
                print(error)
                completionHandlerForUserName(success: false, firstName: nil, lastName: nil, errorString: "There was an error retrieving your account information. Please try again.")
                
            } else {
                
                // Chain of unwrapping optionals from the results
                if let userDict = results["user"] as? [String:AnyObject] {
                    if let firstName = userDict["first_name"] as? String {
                        if let lastName = userDict["last_name"] as? String {
                            // If the unwrapping chain is successful, end the chain
                            completionHandlerForUserName(success: true, firstName: firstName, lastName: lastName, errorString: nil)
                        } else {
                            completionHandlerForUserName(success: false, firstName: nil, lastName: nil, errorString: "There was an error retrieving your account information. Please try again.")
                            print("There was an error unwrapping last_name.")
                        }
                    } else {
                        completionHandlerForUserName(success: false, firstName: nil, lastName: nil, errorString: "There was an error retrieving your account information. Please try again.")
                        print("There was an error unwrapping first_name.")
                    }
                } else {
                    completionHandlerForUserName(success: false, firstName: nil, lastName: nil, errorString: "There was an error retrieving your account information. Please try again.")
                    print("There was an error unwrapping results.")
                }
            }
        }
    }
    
    
    
    // MARK: MapViewController Functions
    
    // Get all student locations
    func getStudentLocations(completionHandlerForStudentLocations: (success: Bool, studentLocations: [MKPointAnnotation]?, errorString: String?) -> Void) {
        
        print("Getting student locations...")
        
        // Creat empty parameters
        let parameters = [String: AnyObject]()
        
        // GET the student locations
        taskForGETMethod(UdacityConstants.ParseApi, method: UdacityConstants.ParseStudentLocations, parameters: parameters) { (results, error) in
            
            if let error = error {
                print(error)
                completionHandlerForStudentLocations(success: false, studentLocations: nil, errorString: "There was an error retrieving student locations.")
            } else {
                
                // Unwrapping results
                guard let resultsArray = results["results"] as? [[String:AnyObject]] else {
                    completionHandlerForStudentLocations(success: false, studentLocations: nil, errorString: "There was an error retrieving student locations.")
                    return
                }
                
                var annotations = [MKPointAnnotation]()
                
                // Loop through each dictionary in the student array
                for result in resultsArray {
                    
                    // Get the latitude and longitude for each student
                    let lat = CLLocationDegrees(result["latitude"] as! Double)
                    let long = CLLocationDegrees(result["longitude"] as! Double)
                    
                    // Create a coordinate for each student
                    let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    
                    // Get the data needed for each student
                    let first = result["firstName"] as! String
                    let last = result["lastName"] as! String
                    let mediaURL = result["mediaURL"] as! String
                    
                    // Create the annotation and set its coordiate, title, and subtitle properties
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate
                    annotation.title = "\(first) \(last)"
                    annotation.subtitle = mediaURL
                    
                    // Place the annotation in an array of annotations.
                    annotations.append(annotation)
                    
                }
                
                completionHandlerForStudentLocations(success: true, studentLocations: annotations, errorString: nil)
            }
            
        }
    }
    
    func locationPostOrPut(completionHandlerForPostOrPut: (success: Bool, errorString: String?) ->Void) {
        
        print("Deciding on POST or PUT...")
        
        guard let uniqueKey = UdacityResources.sharedInstance().udacityId else {
            print("Error receiveing the key")
            return
        }
        
        // Create empty parameters
        var parameters = [String: AnyObject]()
        
        parameters["where"] = "{\"uniqueKey\":\"\(uniqueKey)\"}"
        
        // GET data to test if user as posted before
        taskForGETMethod(UdacityConstants.ParseApi, method: UdacityConstants.ParseStudentLocations, parameters: parameters) { (results, error) in
            
            if let error = error {
                print(error)
                completionHandlerForPostOrPut(success: false, errorString: "There was an error: \(error)")
            } else {
                
                guard let results = results["results"] as? [[String:AnyObject]] else {
                    completionHandlerForPostOrPut(success: false, errorString: "There was an error retrieving some data")
                    return
                }
                
                if results.isEmpty {
                    UdacityResources.sharedInstance().method = "POST"
                    print("No data on the server, using POST")
                } else {
                    UdacityResources.sharedInstance().method = "PUT"
                    print("Data found, using PUT")
                    
                    guard let objectIdDict = results.last else {
                        completionHandlerForPostOrPut(success: false, errorString: "There was an error retrieving some data")
                        return
                    }
                    
                    UdacityResources.sharedInstance().objectId = objectIdDict["objectId"] as? String
                }
                
                completionHandlerForPostOrPut(success: true, errorString: nil)
            }
            
        }
        
        
    }
    
    
    
    // MARK: InputURLViewController functions
    
    func submit(studentData: Student?, completionHandlerForSubmit: (success: Bool, errorString: String?) ->Void) {
        
        print("Submitting the user information...")
        
        guard let key = studentData?.uniqueKey else {
            print("Error with unique key")
            return
        }
        
        guard let firstName = studentData?.firstName else {
            print("Error with first name")
            return
        }
        
        guard let lastName = studentData?.lastName else {
            print("Error with last name")
            return
        }
        
        guard let mapString = studentData?.mapString else {
            print("Error with map string")
            return
        }
        
        guard let mediaUrl = studentData?.mediaURL else {
            print("Error with media URL")
            return
        }
        
        guard let latitude = studentData?.latitude else {
            print("Error with latitude")
            return
        }
        
        guard let longitude = studentData?.longitude else {
            print("Error with longitude")
            return
        }
        
        let jsonBody = "{\"uniqueKey\": \"\(key)\", \"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaUrl)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}"
        
        var method = UdacityConstants.ParseStudentLocations
        
        if UdacityResources.sharedInstance().method! == "PUT" {
            
            guard let objectId = UdacityResources.sharedInstance().objectId else {
                print("Problem with the object ID")
                return
            }
            
            method += "/\(objectId)"
            
        }
        
        var parameters = [String: AnyObject]()
        
        taskForPUTMethod(UdacityConstants.ParseApi, method: method, parameters: parameters, jsonBody: jsonBody) { (results, error) in
            
            if let error = error {
                print(error)
                completionHandlerForSubmit(success: false, errorString: "There was an error submitting the student location.")
            } else {
                print(results)
                completionHandlerForSubmit(success: true, errorString: nil)
            }
            
        }
    }
    
    
    
    // MARK: Logout
    
    func logout(completionHandlerForLogout: (success: Bool, errorString: String?) -> Void) {
        
        print("Logging out...")
        
        let parameters = [String: AnyObject]()
        
        taskForDELETEMethod(UdacityConstants.UdacitySession, parameters: parameters) { (result, error) in
            if let error = error {
                print(error)
                completionHandlerForLogout(success: false, errorString: "There was a problem logging out")
            } else {
                UdacityResources.sharedInstance().sessionId = ""
                UdacityResources.sharedInstance().udacityId = ""
                UdacityResources.sharedInstance().firstName = ""
                UdacityResources.sharedInstance().lastName = ""
                completionHandlerForLogout(success: true, errorString: nil)
            }
        }
    }
}