//
//  ViewControllerUtils.swift
//  SingleSignUp
//
//  Created by Carlos Martin on 12/09/17.
//  Copyright © 2017 Carlos Martin. All rights reserved.
//

import Foundation
import UIKit

class SpinnerLoader {
    var container: UIView = UIView()
    var loadingView: UIView = UIView()
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    init(view: UIView) {
        container.frame = view.frame
        container.center = view.center
        container.backgroundColor = UIColor(red: 255/256.0, green: 255/256.0, blue: 255/256.0, alpha: 0.3)
        
        loadingView.frame = CGRect(x: 0.0, y: 0.0, width: 80.0, height: 80.0)
        loadingView.center = view.center
        loadingView.backgroundColor = UIColor(red: 68/256.0, green: 68/256.0, blue: 68/256.0, alpha: 0.7)
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        
        activityIndicator.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0)
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.center = CGPoint(x: loadingView.frame.size.width/2, y: loadingView.frame.size.height/2)
        
        loadingView.addSubview(activityIndicator)
        container.addSubview(loadingView)
        
    }
    
    func start(_ view: UIView) {
        view.addSubview(container)
        activityIndicator.startAnimating()
    }
    
    func stop() {
        activityIndicator.stopAnimating()
        container.removeFromSuperview()
    }
}
