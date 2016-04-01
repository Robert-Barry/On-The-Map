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
    
    var annotations = [MKPointAnnotation]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
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
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let toOpen = annotations[indexPath.row].subtitle {
            UIApplication.sharedApplication().openURL(NSURL(string: toOpen)!)
        }
    }

}
