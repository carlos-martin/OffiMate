//
//  ForgotPasswordViewController.swift
//  SingleSignUp
//
//  Created by Carlos Martin on 18/10/2017.
//  Copyright © 2017 Carlos Martin. All rights reserved.
//

import UIKit
import FirebaseAuth

class ForgotPasswordViewController: UITableViewController {

    var email: String?
    
    //UI
    var sendButton: UIBarButtonItem!
    var spinner: SpinnerLoader!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initUI()
        self.tableView.reloadData()
        self.startTextField()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func initUI() {
        self.spinner = SpinnerLoader(view: self.tableView, alpha: 0.1)
        self.sendButton = UIBarButtonItem(
            title: "Send",
            style: .done,
            target: self,
            action: #selector(resetAction))
        
        self.navigationItem.rightBarButtonItem = sendButton
        self.navigationItem.title = "Reset"
    }
    
    func startTextField(){
        (self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! ForgetPasswordViewCell).emailTextField.becomeFirstResponder()
    }
    
    @objc func resetAction() {
        self.spinner = SpinnerLoader(view: self.tableView, alpha: 0.1)
        if validTextField() {
            self.spinner?.start()
            self.sendButton.isEnabled = false
            Auth.auth().sendPasswordReset(withEmail: self.email!, completion: { (error: Error?) in
                if let resetError = error {
                    Alert.showFailiureAlert(error: resetError)
                    self.spinner?.stop()
                    self.sendButton.isEnabled = true
                } else {
                    let title = "Reseting password!"
                    let message = "We have sent you an email. Check you email inbox and follow the instructions."
                    Alert.showFailiureAlert(title: title, message: message, handler: { (_) in
                        self.spinner?.stop()
                        self.sendButton.isEnabled = true
                        Tools.goToWaitingRoom(vc: self)
                    })
                }
            })
        } else {
            Alert.showFailiureAlert(title: "Error", message: "Please enter valid email.")
        }
    }
    
    func validTextField () -> Bool {
        var valid: Bool = false
        
        let mailCell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! ForgetPasswordViewCell
        
        if Tools.validateEmail(email: mailCell.emailTextField) {
            valid = true
            self.email = mailCell.emailTextField.text!
            if mailCell.emailTextField.isEditing {
                mailCell.emailTextField.endEditing(true)
            }
        }
        
        return valid
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "What's your email?"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "forgotEmailCell", for: indexPath) as! ForgetPasswordViewCell
        cell.emailTextField.delegate = self
        cell.emailTextField.placeholder = "Enter your email..."
        return cell
    }
    
    //Dismissing Keyboard
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.onDrag
    }
}

//MARK:- TextField
extension ForgotPasswordViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.resetAction()
        return true
    }
}
