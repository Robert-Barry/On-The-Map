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
    
    // OUTLETS
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

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

}
