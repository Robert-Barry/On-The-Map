//
//  LoginViewController.swift
//  On The Map
//
//  Created by Robert Barry on 2/18/16.
//  Copyright © 2016 Robert Barry. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    // CONSTANTS
    let loginTextFieldDelegate = LoginTextFieldDelegate()
    let warningColor = UIColor(colorLiteralRed: 1.0, green: 0.58, blue: 0.58, alpha: 1.0)
    
    // OUTLETS
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginLabel: UILabel!
    
    // VARIABLES
    var email: String!
    var password: String!
    
    
    
    // IOS OVERRIDES
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        emailTextField.delegate = loginTextFieldDelegate
        passwordTextField.delegate = loginTextFieldDelegate
        
        emailTextField.attributedPlaceholder = NSAttributedString(string: "Email",
            attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password",
            attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        subscribeToKeyboardNotifications()
        
        emailTextField.text = ""
        passwordTextField.text = ""
    }
    
    
    
    // ACTIONS
    @IBAction func loginToUdacity(sender: AnyObject) {
        
        // Check for data entered in the text fields
        if (emailTextField.text == "" || !isValidEmail(emailTextField.text!))  && passwordTextField.text == "" {
            loginLabel.font = loginLabel.font.fontWithSize(16)
            loginLabel.textColor = warningColor
            loginLabel.text = "Enter a valid email and password!"
            
            emailTextField.backgroundColor = warningColor
            passwordTextField.backgroundColor = warningColor
            
        // Check for a valid email address
        } else if !isValidEmail(emailTextField.text!) || emailTextField.text == "" {
            loginLabel.font = loginLabel.font.fontWithSize(16)
            loginLabel.textColor = warningColor
            loginLabel.text = "Enter a valid email address!"
            
            emailTextField.backgroundColor = warningColor
            
        } else if passwordTextField.text == "" {
            
            passwordTextField.backgroundColor = warningColor
            loginLabel.text = "Enter a valid password!"
            
        } else {
            
            loginLabel.font = loginLabel.font.fontWithSize(20)
            loginLabel.textColor = UIColor.whiteColor()
            loginLabel.text = "Login to Udacity"
            
            email = emailTextField.text
            password = passwordTextField.text
            
            getSessionAndUdacityID()
            
        }
        
    }
    
    
    
    // HELPER FUNCTIONS
    func getSessionAndUdacityID() {
        print("Session ID called")
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"udacity\": {\"username\": \"\(email)\", \"password\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)

        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            func displayError(error: String) {
                print(error)
                /*
                dispatch_async(dispatch_get_main_queue()) {
                    self.setUIEnabled(true)
                    self.debugTextLabel.text = "Login Failed!"
                }
                */
            }
            
            // GUARD: Was there an error?
            guard (error == nil) else {
                displayError("There was an error with your request: \(error)")
                return
            }
            
            // GUARD: Did we get a successfull 2xx response?
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                displayError("Your request returned a status code other than 2xx: \((response as? NSHTTPURLResponse)?.statusCode))")
                return
            }
            
            // GUARD: Was the data returned
            guard let data = data else {
                displayError("No data was returned by the request!")
                return
            }
            
            // Get the data minus the first 5 characters
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
            
            // Get the parsed result
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments) as? NSDictionary
            } catch {
                print("Could not parse the data with JSON: \(data)")
                return
            }
            
            // GUARD: Is there account data?
            guard let accountDict = parsedResult["account"] as? [String:AnyObject] else {
                print("Could not parse the data: \(parsedResult)")
                return
            }
            
            // GUARD: Is there a Udacity ID
            guard let udacityId = accountDict["key"] as? String else {
                print("Could not parse the data: \(accountDict)")
                return
            }
            
            // GUARD: Is there session data?
            guard let sessionDict = parsedResult["session"] as? [String:AnyObject] else {
                print("Could not parse the data: \(parsedResult)")
                return
            }
            
            // GUARD: is there a session ID
            guard let sessionId = sessionDict["id"] as? String else {
                print("Could not parse the data: \(sessionDict)")
                return
            }
            
            // Save the session ID and Udacity ID as resources.
            UdacityResources.sharedInstance().sessionId = sessionId
            UdacityResources.sharedInstance().udacityId = udacityId
            
            self.getUserName()

        }
        task.resume()
        
    }
    
    func getUserName() {
        print("Get User Name")
        
        guard let udacityId = UdacityResources.sharedInstance().udacityId else {
            print("Error getting guser ID")
            return
        }
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/users/\(udacityId)")!)
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            func displayError(error: String) {
                print(error)
                /*
                 dispatch_async(dispatch_get_main_queue()) {
                 self.setUIEnabled(true)
                 self.debugTextLabel.text = "Login Failed!"
                 }
                 */
            }
            
            // GUARD: Was there an error?
            guard (error == nil) else {
                displayError("There was an error with your request: \(error)")
                return
            }
            
            // GUARD: Did we get a successfull 2xx response?
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                displayError("Your request returned a status code other than 2xx: \((response as? NSHTTPURLResponse)?.statusCode))")
                return
            }
            
            // GUARD: Was the data returned
            guard let data = data else {
                displayError("No data was returned by the request!")
                return
            }
            
            // Get the data minus the first 5 characters
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
            
            // Get the parsed result
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments) as? NSDictionary
            } catch {
                print("Could not parse the data with JSON: \(data)")
                return
            }
            
            guard let userDict = parsedResult["user"] as? [String:AnyObject] else {
                displayError("Could not parse: \(parsedResult)")
                return
            }
            
            guard let firstName = userDict["first_name"] as? String else {
                displayError("Could not parse: \(userDict)")
                return
            }
            
            guard let lastName = userDict["last_name"] as? String else {
                displayError("Could not parse: \(userDict)")
                return
            }
            
            UdacityResources.sharedInstance().firstName = firstName
            UdacityResources.sharedInstance().lastName = lastName
            
            performUIUpdatesOnMain {
                self.goToMap()
            }
            
        }
        task.resume()
    }
    
    // Segue to the map view
    func goToMap() {
        performSegueWithIdentifier("showMap", sender: self)
    }
    
    
    // KEYBOARD FUNCTIONS
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
        
    }
    
    // Move the keyboard to show the bottom text field
    func keyboardShowAndHide(notification: NSNotification) {
        
        // If the notification is WillShow, move the view up
        if notification.name == UIKeyboardWillShowNotification {
            view.frame.origin.y -= getKeyboardHeight(notification) - 150
        } else { // else move the view down
            view.frame.origin.y = 0
        }
        
    }
    
    func subscribeToKeyboardNotifications() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardShowAndHide:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardShowAndHide:", name: UIKeyboardWillHideNotification, object: nil)
        
    }
    
    func unsubscribeFromKeyboardNotifications() {
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        
    }
    
    // Check for a valid email address
    // Code from http://stackoverflow.com/questions/25471114/how-to-validate-an-e-mail-address-in-swift
    func isValidEmail(testStr:String) -> Bool {
        // println("validate calendar: \(testStr)")
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }

}
