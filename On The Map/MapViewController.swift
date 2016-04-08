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


    // OVERRIDES
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    
        getStudentLocations()
        
    }
    

    
    // ACTIONS
    @IBAction func refreshStudentLocations(sender: AnyObject) {
        print("Refreshing...")
        getStudentLocations()
    }
    
    @IBAction func inputLocation(sender: AnyObject) {
        
        UdacityClient.sharedInstance().locationPostOrPut() { (success, error) in
            if success {
                
                // Create an alert if data already exists for this user
                if UdacityResources.sharedInstance().method == "PUT" {
                
                    let message = "You have already posted a student location. Would you like to overwrite your current location?"
                
                    let alert = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
                
                    let okAction = UIAlertAction(title: "Overwrite", style: .Default, handler: { action in
                    
                        self.goToInputUrlVC()
                        
                    })
                
                    let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: { action in
                        return
                    })
                
                    alert.addAction(okAction)
                    alert.addAction(cancelAction)
                
                    performUIUpdatesOnMain {
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                } else {
                    self.goToInputUrlVC()
                }
            } else {
                self.displayError(error!)
            }
        }
    }
    
    @IBAction func logout(sender: AnyObject) {
        print("Logging out")
        
        UdacityClient.sharedInstance().logout() { (success, error) in
            if success {
                print("Success")
                performUIUpdatesOnMain {
                    self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
                }
            } else {
                self.displayError(error!)
            }
            
        }
        
    }
    
    
    
    // HELPER FUNCTIONS
    
    func getStudentLocations() {

        mapView.removeAnnotations(mapView.annotations)
        
        UdacityClient.sharedInstance().getStudentLocations() { (success, error) in
            if success {
                
                // Pull from the annotations array stored in UdacityResources
                guard let annotations = UdacityResources.sharedInstance().studentAnnotations else {
                    return
                }
                
                // Send student data to the Student List View Controller
                let tabBarController = self.navigationController?.tabBarController
                let navController = tabBarController?.viewControllers![1]
                let svc = navController?.childViewControllers[0] as! StudentListViewController
                
                performUIUpdatesOnMain {
                    // When the array is complete, add the annotations to the map.
                    self.mapView.addAnnotations(annotations)
                    svc.annotations = annotations
                }
                
                print("Student locations recieved")
                
            } else {
                self.displayError(error!)
            }
        }
    }
    
    func displayError(errorString: String) {
        // Show an alert
        let alert = UIAlertController(title: "Alert!", message: errorString, preferredStyle: .Alert)
        
        let dismissAction = UIAlertAction(title: "Dismiss", style: .Default, handler: { action in
            
            // reset the UI and dismiss the alert
            alert.dismissViewControllerAnimated(true, completion: nil)
            
        })
        
        alert.addAction(dismissAction)
        
        performUIUpdatesOnMain {
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func goToInputUrlVC() {
        let inputLocationController = self.storyboard?.instantiateViewControllerWithIdentifier("InputLocationViewController")
        self.presentViewController(inputLocationController!, animated: true, completion: nil)
    }
    
    
    // MARK: MapViewDelegate
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            if let toOpen = view.annotation?.subtitle! {
                if let url = NSURL(string: toOpen) {
                    app.openURL(url)
                }
            }
        }
    }
    
    // Create a view with a "right callout accessory view".
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

}
