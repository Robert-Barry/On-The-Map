//
//  InputLocationViewController.swift
//  On The Map
//
//  Created by Robert Barry on 3/31/16.
//  Copyright © 2016 Robert Barry. All rights reserved.
//

import UIKit
import MapKit

class InputLocationViewController: UIViewController {

    // CONSTANTS
    let locationTextFieldDelegate = TextFieldDelegate()
    
    // VARIABLES
    var userLocation: String!
    
    // OUTLETS
    @IBOutlet weak var userLocationTextField: UITextField!
    @IBOutlet weak var activityBackground: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    
    // OVERRIDES
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        userLocationTextField.delegate = locationTextFieldDelegate
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        resetUI()
    }

    
    
    // ACTIONS
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func findOnTheMap(sender: AnyObject) {
        
        activityBackground.hidden = false
        activityIndicator.hidden = false
        
        activityIndicator.startAnimating()
        
        if userLocationTextField.text == "" {
            displayError("You must enter a valid location!")
            return
        }
        
        // Check for an internet connection
        if !UdacityResources.sharedInstance().reachable {
            displayError("There is no internet connection! Find a valid network and try again!")
            return
        }
        
        let controller = storyboard?.instantiateViewControllerWithIdentifier("InputURLViewController") as! InputURLViewController
        
        // Search for map data using a natural search string
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = userLocationTextField.text
        
        let search = MKLocalSearch(request: request)
        
        search.startWithCompletionHandler { (response, error) in
            
            guard (error == nil) else {
                self.displayError("The location was not found! Please try again.")
                self.userLocationTextField.text = ""
                return
            }
            
            guard let newResponse = response else {
                self.displayError("There was a problem with the response")
                self.userLocationTextField.text = ""
                return
            }
            
            var studentData: Student!
            
            for item in newResponse.mapItems {
                studentData = Student(studentDict: ["mapString": item.name!, "latitude": item.placemark.location!.coordinate.latitude, "longitude": item.placemark.location!.coordinate.longitude])
                
            }
            
            controller.studentData = studentData
            self.activityIndicator.stopAnimating()
            
            self.showViewController(controller, sender: self)
            //self.presentViewController(controller, animated: true, completion: nil)
        }
        
    }
    
    
    
    // HELPER FUNCTIONS
    func resetUI() {
        
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        
        // Hide the activty view and background
        activityBackground.hidden = true
        activityIndicator.hidden = true
        
        // Reset the text field
        userLocationTextField.text = ""
        userLocationTextField.attributedPlaceholder = NSAttributedString(string: "Enter Your Location Here",
                                                                         attributes:[NSForegroundColorAttributeName: UIColor.init(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)])
    }
    
    func dismissKeyboard() {
        userLocationTextField.resignFirstResponder()
    }
    
    func displayError(errorString: String) {
        // Show an alert
        let alert = UIAlertController(title: "Alert!", message: errorString, preferredStyle: .Alert)
        
        let dismissAction = UIAlertAction(title: "Dismiss", style: .Default, handler: { action in
            
            // reset the UI and dismiss the alert
            self.resetUI()
            alert.dismissViewControllerAnimated(true, completion: nil)
            
        })
        
        alert.addAction(dismissAction)
        
        performUIUpdatesOnMain {
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
}


    


