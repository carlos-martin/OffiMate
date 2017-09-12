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
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func doneActionButton(_ sender: Any) {
        let emailCell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! EmailLoginViewCell
        let passCell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as! PasswordLoginViewCell
        if Tools.validateEmail(email: emailCell.emailTextField) {
            if Tools.validatePassword(pass: passCell.passwordTextField) {
                Tools.goToMain(vc: self)
            } else {
                Tools.cellViewErrorAnimation(cell: passCell)
            }
        } else {
            Tools.cellViewErrorAnimation(cell: emailCell)
        }
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

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let emailCell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! EmailLoginViewCell
        let passCell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as! PasswordLoginViewCell
        var works: Bool = false
        switch textField.tag {
        case 0:
            //Email section
            if Tools.validateEmail(email: emailCell.emailTextField) {
                passCell.passwordTextField.becomeFirstResponder()
                works = true
            } else {
                Tools.cellViewErrorAnimation(cell: emailCell)
            }
        default:
            //Password section
            if Tools.validateEmail(email: emailCell.emailTextField) {
                if Tools.validatePassword(pass: passCell.passwordTextField) {
                    Tools.goToMain(vc: self)
                    works = true
                } else {
                    Tools.cellViewErrorAnimation(cell: passCell)
                }
            } else {
                Tools.cellViewErrorAnimation(cell: emailCell)
            }
        }
        return works
    }
}
