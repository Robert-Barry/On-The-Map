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
    
    let urlTextFieldDelegate = TextFieldDelegate()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        urlTextField.delegate = urlTextFieldDelegate
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
        self.mapView.delegate = self
        
        print("input url")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        urlTextField.text = ""
        urlTextField.attributedPlaceholder = NSAttributedString(string: "Enter A Link To Share Here",
                                                                         attributes:[NSForegroundColorAttributeName: UIColor.init(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)])
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
        
        // Send the user's information to the server
        UdacityClient.sharedInstance().submit(studentData, completionHandlerForSubmit: { (success, errorString) in
            if success {
                let presentingVC = self.presentingViewController
                
                performUIUpdatesOnMain {
                    self.dismissViewControllerAnimated(false, completion: {
                        presentingVC?.dismissViewControllerAnimated(false, completion: nil)
                    })
                }
            } else {
                self.displayError(errorString!)
            }
        })
        
    }
    
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func dismissKeyboard() {
        urlTextField.resignFirstResponder()
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
    
    func displayError(errorString: String) {
        print(errorString)
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
