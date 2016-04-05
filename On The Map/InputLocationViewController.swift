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
    
    // OVERRIDES
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        userLocationTextField.delegate = locationTextFieldDelegate
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(animated: Bool) {
        
        // Get the Udacity user data to save as a student object
        userLocationTextField.text = ""
        userLocationTextField.attributedPlaceholder = NSAttributedString(string: "Enter Your Location Here",
                                                                         attributes:[NSForegroundColorAttributeName: UIColor.init(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)])
    }

    // ACTIONS
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func findOnTheMap(sender: AnyObject) {
        let controller = storyboard?.instantiateViewControllerWithIdentifier("InputURLViewController") as! InputURLViewController
        
        // Search for map data using a natural search string
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = userLocationTextField.text
        
        let search = MKLocalSearch(request: request)
        
        search.startWithCompletionHandler { (response, error) in
            
            guard (error == nil) else {
                print("There was an error with your request")
                return
            }
            
            guard let newResponse = response else {
                print("There was a problem with the response")
                return
            }
            
            var studentData: Student!
            
            for item in newResponse.mapItems {
                studentData = Student(mapString: item.name!, latitude: item.placemark.location!.coordinate.latitude, longitude: item.placemark.location!.coordinate.longitude)
                
            }
            
            controller.studentData = studentData
            
            self.showViewController(controller, sender: self)
            //self.presentViewController(controller, animated: true, completion: nil)
        }
        
    }
    
    func dismissKeyboard() {
        userLocationTextField.resignFirstResponder()
    }
}


    


