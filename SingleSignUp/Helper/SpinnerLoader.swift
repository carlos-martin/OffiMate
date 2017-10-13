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
    let view: UIView
    var container: UIView = UIView()
    var loadingView: UIView = UIView()
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    init(view: UIView) {
        self.view = view
        
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.extraLight)
            self.container = UIVisualEffectView(effect: blurEffect)
            self.container.frame = UIScreen.main.bounds
            self.container.center = CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/2)
            self.container.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        } else {
            self.container.frame = UIScreen.main.bounds
            self.container.center = CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/2)
            self.container.backgroundColor = UIColor(red: 255/256.0, green: 255/256.0, blue: 255/256.0, alpha: 1.0)
        }
        
        self.loadingView.frame = CGRect(x: 0.0, y: 0.0, width: 80.0, height: 80.0)
        self.loadingView.center = self.container.center
        self.loadingView.backgroundColor = UIColor(red: 68/256.0, green: 68/256.0, blue: 68/256.0, alpha: 0.7)
        self.loadingView.clipsToBounds = true
        self.loadingView.layer.cornerRadius = 12
        
        self.activityIndicator.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0)
        self.activityIndicator.activityIndicatorViewStyle = .whiteLarge
        self.activityIndicator.center = CGPoint(x: loadingView.frame.size.width/2, y: loadingView.frame.size.height/2)
        
        self.loadingView.addSubview(activityIndicator)
        self.container.addSubview(loadingView)
        
    }
    
    func start() {
        self.view.addSubview(container)
        activityIndicator.startAnimating()
    }
    
    func stop() {
        UIView.animate(
            withDuration: 0.5,
            animations: {
                self.container.alpha = 0
            },
            completion: { (_) in
                self.activityIndicator.stopAnimating()
                self.container.removeFromSuperview()
            }
        )
    }
}
