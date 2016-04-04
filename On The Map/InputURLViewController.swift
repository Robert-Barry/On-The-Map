//
//  InputURLViewController.swift
//  On The Map
//
//  Created by Robert Barry on 3/31/16.
//  Copyright © 2016 Robert Barry. All rights reserved.
//

import UIKit
import MapKit

class InputURLViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    var studentData: Student?
    @IBOutlet weak var urlTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.mapView.delegate = self
        
        print("input url")
    }
    
    override func viewDidAppear(animated: Bool) {
        
        let location = CLLocationCoordinate2DMake(studentData!.latitude, studentData!.longitude)
        
        let dropPin = MKPointAnnotation()
        dropPin.coordinate = location
        //dropPin.title = "New York City"
        //mapView.centerCoordinate = location
        let regionToView = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.8, longitudeDelta: 0.8))
        mapView.region = regionToView
        mapView.addAnnotation(dropPin)
        
    }
    
    @IBAction func submit(sender: AnyObject) {
        
        studentData?.mediaURL = urlTextField.text
        
        var urlString: String!
        var url: NSURL!
        
        // UPLOAD DATA HERE!!
        if UdacityResources.sharedInstance().method! == "POST" {
            urlString = "https://api.parse.com/1/classes/StudentLocation"
        } else {
            guard let objectId = UdacityResources.sharedInstance().objectId else {
                print("Problem with the object ID")
                return
            }
            urlString = "https://api.parse.com/1/classes/StudentLocation/\(objectId)"
        }
        
        url = NSURL(string: urlString)
        
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = UdacityResources.sharedInstance().method!
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
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
        
        
        print("{\"uniqueKey\": \"\(key)\", \"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaUrl)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}")
        
        //request.HTTPBody = "{\"uniqueKey\": \"\(key)\", \"firstName\": \"John\", \"lastName\": \"Doe\",\"mapString\": \"Cupertino, CA\", \"mediaURL\": \"https://udacity.com\",\"latitude\": 37.322998, \"longitude\": -122.032182}".dataUsingEncoding(NSUTF8StringEncoding)
        //let session = NSURLSession.sharedSession()
        
        let mapViewController = storyboard?.instantiateViewControllerWithIdentifier("TabBarController")
        presentViewController(mapViewController!, animated: true, completion: nil)
    }
    
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = false
            pinView!.pinTintColor = UIColor(red: 0.9, green: 0.2, blue: 0.2, alpha: 1.0)
            //pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
