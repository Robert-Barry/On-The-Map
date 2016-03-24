//
//  MapViewController.swift
//  On The Map
//
//  Created by Robert Barry on 3/24/16.
//  Copyright © 2016 Robert Barry. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        getStudentLocations()
    }
    

    
    func getStudentLocations() {
        print("Student Locations called")
        
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
            
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? NSDictionary
            } catch {
                print("Could not parse the data with JSON: \(data)")
                return
            }
            print(parsedResult)
            /*
            guard let sessionDict = parsedResult["session"] as? [String:AnyObject] else {
                print("Could not parse the data: \(parsedResult)")
                return
            }
            
            guard let sessionId = sessionDict["id"] as? String else {
                print("Could not parse the data: \(sessionDict)")
                return
            }
            
            // Save the session ID as a resource
            UdacityResources.sharedInstance().sessionId = sessionId
            
            performUIUpdatesOnMain {
                self.goToMap()
            }*/
            
        }
        task.resume()
        
    }
    
    
    func goToMap() {
        performSegueWithIdentifier("showMap", sender: self)
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
 */
    }

}
