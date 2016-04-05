//
//  MapViewController.swift
//  On The Map
//
//  Created by Robert Barry on 3/24/16.
//  Copyright © 2016 Robert Barry. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    
    // OUTLETS
    @IBOutlet weak var mapView: MKMapView!
    
    // VARIABLES
    var annotations = [MKPointAnnotation]()

    // OVERRIDES
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    
        getStudentLocations()
        
    }
    

    // Download student locations for display on the map
    func getStudentLocations() {
        print("Student Locations called")
        
        // Delete all the annotations to start completely fresh
        annotations.removeAll()
        mapView.removeAnnotations(mapView.annotations)
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in

            
            func displayError(error: String) {
                print(error)
                /*
                 dispatch_async(dispatch_get_main_queue()) {
                 self.setUIEnabled(true)
                 self.debugTextLabel.text = "Login Failed!"
                 }
                 */
            }
            
            // GUARD: Was there an error?
            guard (error == nil) else {
                displayError("There was an error with your request: \(error)")
                return
            }
            
            // GUARD: Did we get a successfull 2xx response?
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                displayError("Your request returned a status code other than 2xx: \((response as? NSHTTPURLResponse)?.statusCode))")
                return
            }
            
            // GUARD: Was the data returned
            guard let data = data else {
                displayError("No data was returned by the request!")
                return
            }
            
            // Parse the data
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? NSDictionary
            } catch {
                print("Could not parse the data with JSON: \(data)")
                return
            }
            
            // GUARD: Get the results and save as an array of dictionaries
            guard let resultsArray = parsedResult["results"] as? [[String:AnyObject]] else {
                print("Could not parse the data: \(parsedResult)")
                return
            }
            
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
                self.annotations.append(annotation)
                
            }
            
            // Send student data to the Student List View Controller
            let tabBarController = self.navigationController?.tabBarController
            let navController = tabBarController?.viewControllers![1]
            let svc = navController?.childViewControllers[0] as! StudentListViewController
            
            performUIUpdatesOnMain {
                // When the array is complete, add the annotations to the map.
                self.mapView.addAnnotations(self.annotations)
                svc.annotations = self.annotations
            }

            print("Student locations recieved")
            
        }
        task.resume()
        
    }

    
    // ACTIONS
    @IBAction func refreshStudentLocations(sender: AnyObject) {
        print("Refreshing...")
        getStudentLocations()
    }
    
    
    // MARK: - MKMapViewDelegate
    
    // Create a view with a "right callout accessory view". You might choose to look into other
    // decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath
    // method in TableViewDataSource.
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
 
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor(red: 0.9, green: 0.2, blue: 0.2, alpha: 1.0)
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    @IBAction func inputLocation(sender: AnyObject) {
        
        guard let uniqueKey = UdacityResources.sharedInstance().udacityId else {
            print("Error receiveing the key")
            return
        }
        
        let urlString = "https://api.parse.com/1/classes/StudentLocation?where=%7B%22uniqueKey%22%3A%22\(uniqueKey)%22%7D"
        let url = NSURL(string: urlString)
        
        print(urlString)
        let request = NSMutableURLRequest(URL: url!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            func displayError(error: String) {
                print(error)
                /*
                 dispatch_async(dispatch_get_main_queue()) {
                 self.setUIEnabled(true)
                 self.debugTextLabel.text = "Login Failed!"
                 }
                 */
            }
            
            // GUARD: Was there an error?
            guard (error == nil) else {
                displayError("There was an error with your request: \(error)")
                return
            }
            
            // GUARD: Did we get a successfull 2xx response?
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                displayError("Your request returned a status code other than 2xx: \((response as? NSHTTPURLResponse)?.statusCode))")
                return
            }
            
            // GUARD: Was the data returned
            guard let data = data else {
                displayError("No data was returned by the request!")
                return
            }
            
            // Parse the data
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? NSDictionary
            } catch {
                print("Could not parse the data with JSON: \(data)")
                return
            }
            
            guard let results = parsedResult["results"] as? [[String:AnyObject]] else {
                displayError("Could not parse: \(parsedResult)")
                return
            }
            
            if results.isEmpty {
                UdacityResources.sharedInstance().method = "POST"
                print("No data on the server.")
            } else {
                
                let message = "You have already posted a student location. Would you like to overwrite your current location?"
                
                let alert = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
                
                let okAction = UIAlertAction(title: "Overwrite", style: .Default, handler: { action in
                    UdacityResources.sharedInstance().method = "PUT"
                    print("Data already exists on the server.")
                    
                    guard let objectIdDict = results.last else {
                        displayError("Could not parse: \(results)")
                        return
                    }
                    
                    UdacityResources.sharedInstance().objectId = objectIdDict["objectId"] as? String
                    
                    let inputLocationController = self.storyboard?.instantiateViewControllerWithIdentifier("InputLocationViewController")
                    self.presentViewController(inputLocationController!, animated: true, completion: nil)
                })
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: { action in
                    return
                })
                
                alert.addAction(okAction)
                alert.addAction(cancelAction)
                
                performUIUpdatesOnMain {
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                
            }
            
            
        }
        task.resume()
        
    }
    
    @IBAction func logout(sender: AnyObject) {
        print("Logging out")
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        let session = NSURLSession.sharedSession()
        print("Session")
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            if error != nil { // Handle error…
                return
            }
            
            guard let oldData = data else {
                print("Problem with the data")
                return
            }
            let newData = oldData.subdataWithRange(NSMakeRange(5, oldData.length - 5)) /* subset response data! */
            
            print(NSString(data: newData, encoding: NSUTF8StringEncoding))
            
            performUIUpdatesOnMain {
                self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
            }
            
        }
        task.resume()
        
    }
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            if let toOpen = view.annotation?.subtitle! {
                app.openURL(NSURL(string: toOpen)!)
            }
        }
    }

}
