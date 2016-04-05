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
    var annotations = [MKPointAnnotation]()

    // OVERRIDES
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
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
        let inputLocationController = storyboard?.instantiateViewControllerWithIdentifier("InputLocationViewController")
        presentViewController(inputLocationController!, animated: true, completion: nil)
    }
    
    @IBAction func logout(sender: AnyObject) {
        let tabBarController = self.navigationController?.tabBarController
        let navController = tabBarController?.viewControllers![0]
        let svc = navController?.childViewControllers[0] as! MapViewController
        svc.logout(sender)
        
    }
 
    
    // TABLE VIEW DATA SOURCE
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
    
    
    // TABLE VIEW DELEGATE
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let toOpen = annotations[indexPath.row].subtitle {
            if let url = NSURL(string: toOpen) {
                UIApplication.sharedApplication().openURL(url)
            }
        }
    }

}
