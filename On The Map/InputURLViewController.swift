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
        print(studentData?.toString())
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
        studentData?.toString()
        
        var urlString: String!
        var url: NSURL!
        
        // UPLOAD DATA HERE!!
        if UdacityResources.sharedInstance().method == "POST" {
            urlString = "https://api.parse.com/1/classes/StudentLocation"
            url = NSURL(string: urlString)
        } else {
            guard let objectId = UdacityResources.sharedInstance().objectId else {
                print("Problem with the object ID")
                return
            }
            
            urlString = "https://api.parse.com/1/classes/StudentLocation/\(objectId)"
            url = NSURL(string: urlString)
        }
        
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
