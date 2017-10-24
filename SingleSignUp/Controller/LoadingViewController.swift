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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.start()
    }
    
    private func start () {
        self.spinner = SpinnerLoader(view: self.view)
        self.spinner.start()
        
            if CurrentUser.isInit() {
                CurrentUser.tryToLogin(completion: { (isLogin: Bool, error: Error?) in
                    if !isLogin {
                        self.spinner.stop()
                        self.goToOnboard(vc: self)
                    } else {
                        if CurrentUser.user!.isEmailVerified {
                            Tools.initChannelsList(completion: {
                                Tools.fetchAllOffices(completion: { (allOffices: [Office]) in
                                    CurrentUser.allOffices = allOffices
                                    self.spinner.stop()
                                    Tools.removeChannelObserver()
                                    self.goToMain(vc: self)
                                })
                            })
                        } else {
                            let title = "Email Not Verified"
                            let message = "Your email has not yet been verified. Do you want us to send another verification email to \(CurrentUser.email!)?"
                            let verifytxt = "Check you email inbox, verify your account and try to login again"
                            Alert.showAlertOptions(
                                title: title, message: message,
                                okAction: { (_) in
                                    CurrentUser.user!.sendEmailVerification(completion: { (emailError: Error?) in
                                        self.spinner.stop()
                                        if emailError == nil {
                                            self.goToOnboard(vc: self, text: verifytxt)
                                        } else {
                                            Alert.showFailiureAlert(error: emailError!, handler: { (_) in
                                                self.goToOnboard(vc: self)
                                            })
                                        }
                                    }) },
                                cancelAction: { (_) in
                                    self.spinner.stop()
                                    self.goToOnboard(vc: self, text: verifytxt)})
                        }
                    }
                })
            } else {
                self.spinner.stop()
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
    
    private func goToOnboard (vc: UIViewController, text: String?=nil) {
        if let message = text {
            Alert.showFailiureAlert(message: message) { (_) in
                if let controller = UIStoryboard(name: "Onboard", bundle: nil).instantiateInitialViewController() {
                    controller.modalPresentationStyle = .fullScreen
                    controller.modalTransitionStyle = .coverVertical
                    vc.present(controller, animated: true, completion: nil)
                }
            }
        } else {
            if let controller = UIStoryboard(name: "Onboard", bundle: nil).instantiateInitialViewController() {
                controller.modalPresentationStyle = .fullScreen
                controller.modalTransitionStyle = .coverVertical
                vc.present(controller, animated: true, completion: nil)
            }
        }
    }

}
