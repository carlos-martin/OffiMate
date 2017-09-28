//
//  CoworkersViewController.swift
//  SingleSignUp
//
//  Created by Carlos Martin on 27/09/2017.
//  Copyright © 2017 Carlos Martin. All rights reserved.
//

import UIKit

class CoworkersViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initUI()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func initUI() {
        self.navigationItem.title = "Coworkers"
    }

}
