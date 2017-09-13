//
//  PasswordViewController.swift
//  SingleSignUp
//
//  Created by Carlos Martin on 23/08/17.
//  Copyright © 2017 Carlos Martin. All rights reserved.
//

import Foundation
import UIKit

class PasswordViewController: UIViewController {
    
    var username: String?
    var email:    String?
    var password: String?
    
    //MARK: IBOutlet
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: IBAction
    @IBAction func saveActionButton(_ sender: Any) {
        self.saveAction(sender)
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
        (self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! PasswordSignUpViewCell).passwordTextField.becomeFirstResponder()
    }
    
    //MARK: Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toConfirm", let nextScene = segue.destination as? ConfirmViewController {
            nextScene.username = self.username
            nextScene.email =    self.email
            nextScene.password = self.password
        }
    }
    
    func saveAction (_ sender: Any?=nil) {
        if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) {
            if self.readyToSave(cell: cell) {
                do {
                    try CurrentUser.setData(name: self.username!, email: self.email!, password: self.password!)
                    try CurrentUser.localSave()
                    Tools.goToMain(vc: self)
                } catch {
                    Tools.cellViewErrorAnimation(cell: cell)
                }
                
            } else {
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
        return cell
    }

    //Dismissing Keyboard
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.onDrag
    }
}

//MARK: - TextField
extension PasswordViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.saveAction()
        return true
    }
}
