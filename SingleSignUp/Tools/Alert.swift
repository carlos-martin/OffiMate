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
}
