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
    let loginTextFieldDelegate = TextFieldDelegate()
    let warningColor = UIColor(colorLiteralRed: 1.0, green: 0.58, blue: 0.58, alpha: 1.0)
    
    // OUTLETS
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var actvityBackground: UIView!
    
    // VARIABLES
    var email: String!
    var password: String!
    
    
    
    // IOS OVERRIDES
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        emailTextField.delegate = loginTextFieldDelegate
        passwordTextField.delegate = loginTextFieldDelegate
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        subscribeToKeyboardNotifications()
        
        resetUI()
        
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
            
            actvityBackground.hidden = false
            activityIndicator.hidden = false
            
            activityIndicator.startAnimating()
            
            
            loginLabel.font = loginLabel.font.fontWithSize(20)
            loginLabel.textColor = UIColor.whiteColor()
            loginLabel.text = "Login to Udacity"
            
            email = emailTextField.text
            password = passwordTextField.text
            
            // Create the post body for getting session and Udacity IDs
            let postBody = "{\"udacity\": {\"username\": \"\(email)\", \"password\": \"\(password)\"}}"
            
            // Authenticate the user's login
            UdacityClient.sharedInstance().authenticate(postBody, completionHandlerForAuth: { (success, errorString) in
                if success {
                    performUIUpdatesOnMain {
                        // Go to the next view
                        self.activityIndicator.stopAnimating()
                        self.goToMap()
                    }
                } else {
                    self.displayError(errorString!)

                }
            })
            
        }
        
    }
    
    
    
    // HELPER FUNCTIONS
    
    func displayError(errorString: String) {
        
        print(errorString)
        
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
    
    // Segue to the map view
    func goToMap() {
        performSegueWithIdentifier("showMap", sender: self)
    }
    
    // Check for a valid email address
    // Code from http://stackoverflow.com/questions/25471114/how-to-validate-an-e-mail-address-in-swift
    func isValidEmail(testStr:String) -> Bool {
        // println("validate calendar: \(testStr)")
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
    
    func resetUI() {
        
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        
        // Clear the actitivity view
        activityIndicator.hidden = true
        actvityBackground.hidden = true
        
        // Clear the text fields
        emailTextField.text = ""
        passwordTextField.text = ""
        
        // Give placeholder text to both text fields
        emailTextField.attributedPlaceholder = NSAttributedString(string: "Email",
                                                                  attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password",
                                                                     attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
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
            if view.frame.origin.y == 0 {
                view.frame.origin.y -= getKeyboardHeight(notification) - 150
            }
        } else { // else move the view down
            view.frame.origin.y = 0
        }
        
    }
    
    func subscribeToKeyboardNotifications() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardShowAndHide), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardShowAndHide), name: UIKeyboardWillHideNotification, object: nil)
        
    }
    
    func unsubscribeFromKeyboardNotifications() {
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        
    }

}
