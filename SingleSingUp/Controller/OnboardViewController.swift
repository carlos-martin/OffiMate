//
//  OnboardViewController.swift
//  SingleSingUp
//
//  Created by Carlos Martin on 21/08/17.
//  Copyright © 2017 Carlos Martin. All rights reserved.
//

import UIKit

class OnboardViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelActionButton(_ sender: Any) {
        self.goToMain()
    }
    
    func goToMain () {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
        controller?.modalPresentationStyle = .popover
        controller?.modalTransitionStyle = .flipHorizontal
        self.present(controller!, animated: true, completion: nil)
    }
    
}
