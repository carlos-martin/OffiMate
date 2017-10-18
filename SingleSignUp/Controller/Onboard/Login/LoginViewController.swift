//
//  LoginViewController.swift
//  SingleSignUp
//
//  Created by Carlos Martin on 22/08/17.
//  Copyright © 2017 Carlos Martin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

enum LoginSection: Int {
    case mail = 0
    case pass
}

class LoginViewController: UIViewController {
    
    var username: String?
    var password: String?
    var spinner:  SpinnerLoader?
    var isHidden: Bool = true
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    @IBAction func doneActionButton(_ sender: Any) {
        self.logInAction(sender)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.reloadData()
        self.startTextField()
        spinner = SpinnerLoader(view: self.view, alpha: 0.1)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func startTextField(){
        (self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! EmailLoginViewCell).emailTextField.becomeFirstResponder()
    }
    
    func logInAction (_ sender: Any?=nil) {
        spinner = SpinnerLoader(view: self.view, alpha: 0.1)
        if self.validTextFields() {
            self.spinner?.start()
            self.doneBarButton.isEnabled = false
            Auth.auth().signIn(withEmail: self.username!, password: self.password!, completion: { (user: User?, error: Error?) in
                
                if let nserror = error {
                    Alert.showFailiureAlert(error: nserror)
                    self.spinner?.stop()
                    self.doneBarButton.isEnabled = true
                } else {
                    CurrentUser.user = user
                    Tools.fetchCoworker(uid: user!.uid, completion: { (_, name: String?, coworkerId: String?) in
                        let username = (name != nil ? name! : "#logInAction#")
                        do {
                            try CurrentUser.setData(name: username, email: self.username!, password: self.password!, coworkerId: coworkerId!)
                            try CurrentUser.localSave()
                        } catch {
                            Alert.showFailiureAlert(message: "Ops! Something goes wrong!")
                        }
                        
                        if user!.isEmailVerified {
                            self.spinner?.stop()
                            self.doneBarButton.isEnabled = true
                            Tools.goToMain(vc: self)
                        } else {
                            self.spinner?.stop()
                            self.doneBarButton.isEnabled = true
                            Tools.goToWaitingRoom(vc: self)
                        }
                    })
                }
            })
        } else {
            Alert.showFailiureAlert(title: "Error", message: "Please enter valid user and password.")
        }
    }
    
    func validTextFields () -> Bool {
        var valid: Bool = true
        
        let mailCell = self.tableView.cellForRow(at: IndexPath(row: 0, section: LoginSection.mail.rawValue)) as! EmailLoginViewCell
        let passCell = self.tableView.cellForRow(at: IndexPath(row: 0, section: LoginSection.pass.rawValue)) as! PasswordLoginViewCell
        
        if Tools.validateEmail(email: mailCell.emailTextField) {
            self.username = mailCell.emailTextField.text!
        } else {
            valid = false
            Tools.cellViewErrorAnimation(cell: mailCell)
        }
        
        if Tools.validatePassword(pass: passCell.passwordTextField) {
            self.password = passCell.passwordTextField.text!
        } else {
            valid = false
            Tools.cellViewErrorAnimation(cell: passCell)
        }
        
        if valid {
            if mailCell.emailTextField.isEditing {
                mailCell.emailTextField.endEditing(true)
            }
            if passCell.passwordTextField.isEditing {
                passCell.passwordTextField.endEditing(true)
            }
        }
        
        return valid
    }
    
}

//MARK: - TableView
extension LoginViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let currentSection: LoginSection = LoginSection(rawValue: section) {
            switch currentSection {
            case .mail:
                return "E-mail"
            case .pass:
                return "Password"
            }
        } else {
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let currentSection: LoginSection = LoginSection(rawValue: indexPath.section) {
            switch currentSection {
            case .mail:
                let cell = tableView.dequeueReusableCell(withIdentifier: "emailLoginCell", for: indexPath) as! EmailLoginViewCell
                cell.emailTextField.delegate = self
                cell.emailTextField.placeholder = "Enter your email..."
                cell.emailTextField.tag = indexPath.section
                return cell
            case .pass:
                let cell = tableView.dequeueReusableCell(withIdentifier: "passLoginCell", for: indexPath) as! PasswordLoginViewCell
                cell.passwordTextField.delegate = self
                cell.passwordTextField.placeholder = "Enter your password..."
                cell.passwordTextField.tag = indexPath.section
                cell.passwordTextField.clearsOnBeginEditing = false
                cell.showHideButton.addTarget(self, action: #selector(showHidePassword(_:)), for: UIControlEvents.touchUpInside)
                return cell
            }
        } else {
            return UITableViewCell()
        }
    }
    
    func showHidePassword (_ sender: Any) {
        let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: LoginSection.pass.rawValue)) as! PasswordLoginViewCell
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

//MARK:- TextField
extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField.tag {
        case 0:
            (self.tableView.cellForRow(at: IndexPath(row: 0, section: LoginSection.pass.rawValue)) as! PasswordLoginViewCell).passwordTextField.becomeFirstResponder()
        default:
            self.logInAction()
        }
        return true
    }
}
