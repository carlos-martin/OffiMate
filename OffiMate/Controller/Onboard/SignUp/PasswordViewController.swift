//
//  PasswordViewController.swift
//  SingleSignUp
//
//  Created by Carlos Martin on 23/08/17.
//  Copyright © 2017 Carlos Martin. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth

let OFFICE_ID = "-Kx7x0OQt_XbVzqVcbX2"

class PasswordViewController: UIViewController {
    
    var username: String?
    var email:    String?
    var password: String?
    var officeId: String?
    var spinner:  SpinnerLoader?
    var isHidden: Bool = true
    
    //MARK: IBOutlet
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var helpLabel: UILabel!
    
    //MARK: IBAction
    @IBAction func saveActionButton(_ sender: Any) {
        self.signUpAction(sender)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initUI()
        self.tableView.reloadData()
        self.startTextField()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func initUI () {
        //Help text
        let helpText: String = "The password must comply with the following restrictions:\n  - at least one uppercase\n  - at least one lowercase\n  - at least one number\n  - at least one of those character: !%*?&"
        self.helpLabel.text = helpText
        self.helpLabel.sizeToFit()
        
        //Init spinner
        self.spinner = SpinnerLoader(view: self.view, alpha: 0.1)
    }
    
    private func startTextField(){
        (self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! PasswordSignUpViewCell).passwordTextField.becomeFirstResponder()
    }
    
    func signUpAction (_ sender: Any?=nil) {
        self.spinner = SpinnerLoader(view: self.view, alpha: 0.1)
        if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) {
            if self.readyToSave(cell: cell) {
                self.spinner?.start()
                
                Auth.auth().createUser(withEmail: self.email!, password: self.password!, completion: { (user: User?, error: Error?) in
                    self.spinner?.stop()
                    if error == nil {
                        user!.sendEmailVerification(completion: { (emailError: Error?) in
                            if emailError == nil {
                                CurrentUser.user = user!
                                let coworkerId = Tools.createCoworker(uid: user!.uid, email: self.email!, name: self.username!, officeId: self.officeId!)
                                do {
                                    try CurrentUser.setData(name: self.username!, email: self.email!, password: self.password!, coworkerId: coworkerId)
                                    try CurrentUser.localSave()
                                } catch {
                                    Tools.cellViewErrorAnimation(cell: cell)
                                }
                                Tools.goToWaitingRoom(vc: self)
                            } else {
                                Alert.showFailiureAlert(error: emailError!)
                            }
                        })
                    } else {
                        Alert.showFailiureAlert(error: error!, handler: { (_) in
                            self.navigationController?.popToRootViewController(animated: true)
                            self.dismiss(animated: true, completion: nil)
                        })
                    }
                })
                
            } else {
                let title = "Validation Password Error"
                let message = "The password must be a minimum of 8 characters and must contain at least one uppercase, one lowercase, one number and one special character."
                Alert.showFailiureAlert(title: title, message: message)
                Tools.cellViewErrorAnimation(cell: cell)
            }
        }
    }
    
    func readyToSave(cell: UITableViewCell) -> Bool {
        var isReady: Bool = false
        if let textField = (cell as! PasswordSignUpViewCell).passwordTextField {
            if Tools.validatePassword(pass: textField) {
                isReady = true
                self.password = textField.text!
            }
        }
        return isReady
    }
    
}

//MARK: - TableView
extension PasswordViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Add a password for your account"
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "passSignUpCell", for: indexPath) as! PasswordSignUpViewCell
        cell.passwordTextField.delegate = self
        cell.passwordTextField.placeholder = "Enter password..."
        cell.passwordTextField.tag = indexPath.row
        cell.passwordTextField.clearsOnBeginEditing = false
        cell.showHideButton.addTarget(self, action: #selector(showHidePassword(_:)), for: UIControlEvents.touchUpInside)
        return cell
    }
    
    @objc func showHidePassword (_ sender: Any) {
        let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! PasswordSignUpViewCell
        if self.isHidden {
            self.isHidden = false
            cell.showHideButton.setImage(UIImage(named: "hide"), for: .normal)
            cell.passwordTextField.isSecureTextEntry = false
        } else {
            self.isHidden = true
            cell.showHideButton.setImage(UIImage(named: "show"), for: .normal)
            cell.passwordTextField.isSecureTextEntry = true
        }
    }

    //Dismissing Keyboard
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.onDrag
    }
}

//MARK: - TextField
extension PasswordViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.signUpAction()
        return true
    }
}
