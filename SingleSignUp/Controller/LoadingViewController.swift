//
//  LoadingViewController.swift
//  SingleSignUp
//
//  Created by Carlos Martin on 16/10/2017.
//  Copyright © 2017 Carlos Martin. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController {

    var spinner: SpinnerLoader!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.spinner = SpinnerLoader(view: self.view)
        self.spinner.start()
        if CurrentUser.isInit() {
            CurrentUser.tryToLogin(completion: { (isLogin: Bool, error: Error?) in
                if !isLogin {
                    self.spinner.stop()
                    self.goToOnboard(vc: self)
                } else {
                    Tools.initChannelsList(completion: {
                        self.spinner.stop()
                        Tools.removeChannelObserver()
                        self.goToMain(vc: self)
                    })
                }
            })
        } else {
            self.goToOnboard(vc: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //.coverVertical .flipHorizontal .crossDissolve
    private func goToMain (vc: UIViewController) {
        if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() {
            controller.modalPresentationStyle = .fullScreen
            controller.modalTransitionStyle = .coverVertical
            vc.present(controller, animated: true, completion: nil)
        }
    }
    
    private func goToOnboard (vc: UIViewController) {
        if let controller = UIStoryboard(name: "Onboard", bundle: nil).instantiateInitialViewController() {
            controller.modalPresentationStyle = .fullScreen
            controller.modalTransitionStyle = .coverVertical
            vc.present(controller, animated: true, completion: nil)
        }
    }

}
