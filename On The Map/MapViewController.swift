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
    
    @IBOutlet weak var mapView: MKMapView!
    
    var annotations = [MKPointAnnotation]()

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
            
            guard let resultsArray = parsedResult["results"] as? [[String:AnyObject]] else {
                print("Could not parse the data: \(parsedResult)")
                return
            }
            
            for result in resultsArray {
                
                let lat = CLLocationDegrees(result["latitude"] as! Double)
                let long = CLLocationDegrees(result["longitude"] as! Double)
                
                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                
                let first = result["firstName"] as! String
                let last = result["lastName"] as! String
                let mediaURL = result["mediaURL"] as! String
                
                // Here we create the annotation and set its coordiate, title, and subtitle properties
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = "\(first) \(last)"
                annotation.subtitle = mediaURL
                
                // Finally we place the annotation in an array of annotations.
                self.annotations.append(annotation)
                
            }
            
            // Send student data to the Student List View Controller
            let tabBarController = self.navigationController?.tabBarController
            let navController = tabBarController?.viewControllers![1]
            let svc = navController?.childViewControllers[0] as! StudentListViewController
            svc.annotations = self.annotations
           
            
            performUIUpdatesOnMain {
                // When the array is complete, we add the annotations to the map.
                self.mapView.addAnnotations(self.annotations)
            }

            print("Student locations recieved")
            
        }
        task.resume()
        
    }

    @IBAction func refreshStudentLocations(sender: AnyObject) {
        print("Refreshing...")
        getStudentLocations()
    }
    // MARK: - MKMapViewDelegate
    
    // Here we create a view with a "right callout accessory view". You might choose to look into other
    // decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath
    // method in TableViewDataSource.
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
 
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
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
