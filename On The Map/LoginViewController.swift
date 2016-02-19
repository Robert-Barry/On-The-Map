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
    }
    
    
    
    // ACTIONS
    @IBAction func loginToUdacity(sender: AnyObject) {
        
        if emailTextField.text == "" || passwordTextField.text == "" {
            loginLabel.font = loginLabel.font.fontWithSize(16)
            loginLabel.textColor = warningColor
            loginLabel.text = "Enter a valid email and password!"
        } else if !isValidEmail(emailTextField.text!) {
            loginLabel.font = loginLabel.font.fontWithSize(16)
            loginLabel.textColor = warningColor
            loginLabel.text = "Enter a valid email address!"
        } else {
            print("Button pressed")
        }
        
    }
    
    
    
    // HELPER FUNCTIONS
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
    
    func isValidEmail(testStr:String) -> Bool {
        // println("validate calendar: \(testStr)")
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }

}
