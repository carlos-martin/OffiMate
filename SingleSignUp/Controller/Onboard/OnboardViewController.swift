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
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    //MARK: IBAction
    @IBAction func cancelActionButton(_ sender: Any) {
        self.goToMain()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.initButtons()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func goToMain () {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
        controller?.modalPresentationStyle = .popover
        controller?.modalTransitionStyle = .flipHorizontal
        self.present(controller!, animated: true, completion: nil)
    }
    
    private func initButtons () {
        self.signUpButton.layer.cornerRadius = 15
        self.loginButton.layer.cornerRadius = 15
    }
    
}
