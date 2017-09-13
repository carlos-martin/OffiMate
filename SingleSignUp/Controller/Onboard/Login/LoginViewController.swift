//
//  LoginViewController.swift
//  SingleSignUp
//
//  Created by Carlos Martin on 22/08/17.
//  Copyright © 2017 Carlos Martin. All rights reserved.
//

import Foundation
import UIKit

class LoginViewController: UIViewController {
    
    var username: String?
    var password: String?
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func doneActionButton(_ sender: Any) {
        self.logInAction(sender)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.tableView.reloadData()
        self.startTextField()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func startTextField(){
        (self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! EmailLoginViewCell).emailTextField.becomeFirstResponder()
    }
    
    func logInAction (_ sender: Any?=nil) {
        if self.validTextFields() {
            Alert.showFailiureAlert(message: "Not implemented yet.")
        } else {
            Alert.showFailiureAlert(message: "Please enter valid user and password.")
        }
    }
    
    func validTextFields () -> Bool {
        var valid: Bool = true
        
        let mailCell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! EmailLoginViewCell
        let passCell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as! PasswordLoginViewCell
        
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
        switch section {
        case 0:
            return "E-mail"
        default:
            return "Password"
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "emailLoginCell", for: indexPath) as! EmailLoginViewCell
            cell.emailTextField.delegate = self
            cell.emailTextField.placeholder = "Enter your email..."
            cell.emailTextField.tag = indexPath.section
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "passLoginCell", for: indexPath) as! PasswordLoginViewCell
            cell.passwordTextField.delegate = self
            cell.passwordTextField.placeholder = "Enter your password..."
            cell.passwordTextField.tag = indexPath.section
            return cell
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
            (self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as! PasswordLoginViewCell).passwordTextField.becomeFirstResponder()
        default:
            self.logInAction()
        }
        return true
    }
}
