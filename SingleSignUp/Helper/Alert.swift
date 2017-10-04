//
//  Alert.swift
//  SingleSignUp
//
//  Created by Carlos Martin on 23/08/17.
//  Copyright © 2017 Carlos Martin. All rights reserved.
//

import Foundation
import UIKit

class Alert {
    static func showFailiureAlert(message: String, handler: (((UIAlertAction)?) -> Void)? = nil) {
        let alertTitle = message
        let alertButtonTitle = "OK"
        
        let alert = UIAlertController(title: alertTitle, message: nil, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: alertButtonTitle, style: UIAlertActionStyle.default, handler: handler))
        
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            topController.present(alert, animated: true, completion: nil)
        }
    }
    
    static func showAlertOptions(title: String, message: String, okAction: (((UIAlertAction)?) -> Void)? = nil, cancelAction: (((UIAlertAction)?) -> Void)? = nil) {
        let alertButtonOK =     "OK"
        let alertButtonCancel = "Cancel"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: alertButtonOK,     style: UIAlertActionStyle.default, handler: okAction))
        alert.addAction(UIAlertAction(title: alertButtonCancel, style: UIAlertActionStyle.cancel,  handler: cancelAction))
        
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            topController.present(alert, animated: true, completion: nil)
        }
    }
    
    static func showFailiureAlert(error: Error, handler: (((UIAlertAction)?) -> Void)? = nil) {
        let nserror = error as NSError
        let message = "Error: " + (nserror.userInfo["NSLocalizedDescription"] as? String ?? "Not identify error.")
        self.showFailiureAlert(message: message, handler: handler)
    }
}
