//
//  StudentListViewController.swift
//  On The Map
//
//  Created by Robert Barry on 3/25/16.
//  Copyright © 2016 Robert Barry. All rights reserved.
//

import UIKit
import MapKit

class StudentListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // Variables
    var annotations: [MKPointAnnotation]!
    
    
    // OVERRIDES
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let newAnnotations = UdacityResources.sharedInstance().studentAnnotations else {
            displayError("There was an error receiving student locations.")
            return
        }
        
        annotations = newAnnotations
    }
    
    

    // ACTIONS
    @IBAction func refreshStudentData(sender: AnyObject) {
        print("Refresh...")
        
        let tabBarController = self.navigationController?.tabBarController
        let navController = tabBarController?.viewControllers![0]
        let svc = navController?.childViewControllers[0] as! MapViewController
        svc.getStudentLocations()
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
        let tabBarController = self.navigationController?.tabBarController
        let navController = tabBarController?.viewControllers![0]
        let svc = navController?.childViewControllers[0] as! MapViewController
        svc.logout(sender)
        
    }
 
    
    // MARK: TABLE VIEW DATA SOURCE
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return annotations.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("StudentCell")!
        let annotation = self.annotations[indexPath.row]
        
        if let title = annotation.title {
            cell.textLabel?.text = title
        }
        
        if let subtitle = annotation.subtitle {
            if let detailTextLabel = cell.detailTextLabel {
                detailTextLabel.text = "\(subtitle)"
            }
        }
        
        cell.imageView?.image = UIImage(named: "mapNav")
        
        return cell
    }
    
    
    
    // HELPER FUNCTIONS
    
    func goToInputUrlVC() {
        let inputLocationController = self.storyboard?.instantiateViewControllerWithIdentifier("InputLocationViewController")
        self.presentViewController(inputLocationController!, animated: true, completion: nil)
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
    
    
    // MARK: TABLE VIEW DELEGATE
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let toOpen = annotations[indexPath.row].subtitle {
            if let url = NSURL(string: toOpen) {
                UIApplication.sharedApplication().openURL(url)
            }
        }
    }

}
