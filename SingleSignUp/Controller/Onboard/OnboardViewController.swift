//
//  OnboardViewController.swift
//  SingleSignUp
//
//  Created by Carlos Martin on 21/08/17.
//  Copyright © 2017 Carlos Martin. All rights reserved.
//

import UIKit

class OnboardViewController: UIViewController {
    
    //MARK: IBOutlet
    @IBOutlet weak var signUpButton:    UIButton!
    @IBOutlet weak var loginButton:     UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initButtons()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func initButtons () {
        self.signUpButton.layer.cornerRadius = 18
        self.loginButton.layer.cornerRadius = 18
    }
    
}
