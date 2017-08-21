//
//  MainViewController.swift
//  SingleSingUp
//
//  Created by Carlos Martin on 21/08/17.
//  Copyright © 2017 Carlos Martin. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onboardActionButton(_ sender: Any) {
        self.goToOnboard()
    }
    
    func goToOnboard () {
        let controller = UIStoryboard(name: "Onboard", bundle: nil).instantiateInitialViewController()
        controller?.modalPresentationStyle = .popover
        controller?.modalTransitionStyle = .flipHorizontal
        self.present(controller!, animated: true, completion: nil)
    }

}

