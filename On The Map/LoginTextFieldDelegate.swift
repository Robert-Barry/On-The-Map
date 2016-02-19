//
//  LoginTextFieldDelegate.swift
//  On The Map
//
//  Created by Robert Barry on 2/18/16.
//  Copyright © 2016 Robert Barry. All rights reserved.
//

import Foundation
import UIKit

class LoginTextFieldDelegate: NSObject, UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        
        textField.attributedPlaceholder = nil
        
        return true
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
        
    }
    
}
