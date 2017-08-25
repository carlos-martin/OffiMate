//
//  Tools.swift
//  SingleSignUp
//
//  Created by Carlos Martin on 23/08/17.
//  Copyright © 2017 Carlos Martin. All rights reserved.
//

import Foundation
//
//  Tools.swift
//  Connet
//
//  Created by Carlos Martin (SE) on 25/10/2016.
//  Copyright © 2016 TUVA Sweden AB. All rights reserved.
//

import Foundation
import UIKit

public class Tools {
    static func randomString(length: Int?=12) -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length! {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
    
    static func validateEmail (email: UITextField) -> Bool {
        if let _email = email.text {
            return self.validateEmail(email: _email)
        } else {
            return false
        }
    }
    
    static func validateEmail (email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)

        return emailTest.evaluate(with: email)
    }
    
    static func validateURL (url: UITextField) -> Bool {
        return self.validateURL(url: url.text!)
    }
    
    static func validateURL (url: String) -> Bool {
        let successful: Bool
        if let url = NSURL(string: url) {
            successful = UIApplication.shared.canOpenURL(url as URL)
        } else {
            successful = false
        }
        return successful
        
    }
    
    static func validateSingelPassword (pass: UITextField, animated: Bool=false) -> Bool {
        let result: Bool
        
        if Tools.textFieldIsEmpty(textField: pass) {
            Alert.showFailiureAlert(message: "The password field cannot be empty.", handler: { (_) in
                if animated {
                    Tools.textFieldErrorAnimation(textField: pass)
                }
            })
            result = false
        } else {
            if !validatePassword(pass: pass.text!) {
                Alert.showFailiureAlert(message: "The password field has to have at least 8 characters.", handler: { (_) in
                    if animated {
                        Tools.textFieldErrorAnimation(textField: pass)
                    }
                })
                result = false
            } else {
                result = true
            }
        }
        
        return result
    }
    
    static func validatePassword (pass: String) -> Bool {
        return (pass.characters.count < 8 ? false : true)
    }
    
    static func validateDescription (desc: UITextView) -> Bool {
        return !desc.text.isEmpty
    }
    
    static func validateBetweenPassword (pass1: UITextField, pass2: UITextField) -> Bool {
        return pass1.text == pass2.text
    }
    
    static func textFieldIsEmpty (textField: UITextField) -> Bool {
        return (textField.text?.isEmpty ?? true)
    }
    
    static func textFieldErrorAnimation (textField: UITextField) {
        textField.backgroundColor = UIColor.red
        UIView.animate(withDuration: 1, animations: {
            textField.alpha = 0.0
        }, completion: { (finished: Bool) in
            textField.backgroundColor = UIColor.white
            textField.alpha = 1
        })
    }
    
    static func cellViewErrorAnimation (cell: UITableViewCell) {
        let view = cell.contentView
        view.backgroundColor = UIColor.red
        UIView.animate(withDuration: 1, animations: { 
            view.alpha = 0.0
        }) { (finished: Bool) in
            view.backgroundColor = UIColor.white
            view.alpha = 1
        }
    }
}
