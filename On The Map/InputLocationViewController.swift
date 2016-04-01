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

    var userLocation: String!
    
    @IBOutlet weak var userLocationTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        userLocationTextField.text = ""
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let controller = segue.destinationViewController as! InputURLViewController
        
        controller.location = userLocationTextField.text
        
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
            
            for item in newResponse.mapItems {
                print("Name: \(item.name)")
                print("Latitude: \(item.placemark.location!.coordinate.latitude)")
                print("Longitude: \(item.placemark.location!.coordinate.longitude)")
            }
        }
    }

    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
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
