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

class PasswordViewController: UIViewController {
    
    var username: String?
    var email:    String?
    var password: String?
    var loader:   SpinnerLoader?
    var isHidden: Bool = true
    
    //MARK: IBOutlet
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: IBAction
    @IBAction func saveActionButton(_ sender: Any) {
        self.signUpAction(sender)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.reloadData()
        
        self.startTextField()
        
        loader = SpinnerLoader(view: self.view)
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
    
    func signUpAction (_ sender: Any?=nil) {
        if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) {
            if self.readyToSave(cell: cell) {
                do {
                    self.loader?.start(self.view)
                    try CurrentUser.setData(name: self.username!, email: self.email!, password: self.password!)
                    try CurrentUser.localSave()
                    
                    Auth.auth().createUser(withEmail: self.email!, password: self.password!, completion: { (user: User?, error: Error?) in
                        self.loader?.stop()
                        if error == nil {
                            CurrentUser.user = user!
                            self.createCoworker(uid: user!.uid, email: self.email!, name: self.username!)
                            Tools.goToMain(vc: self)
                        } else {
                            Alert.showFailiureAlert(message: "Error: \(error.debugDescription)")
                        }
                    })
                } catch {
                    self.loader?.stop()
                    Tools.cellViewErrorAnimation(cell: cell)
                }
            } else {
                Tools.cellViewErrorAnimation(cell: cell)
            }
        }
    }
    
    func createCoworker(uid: String, email: String, name: String) {
        let coworkerRef = Database.database().reference().child("coworkers")
        let newCoworkerRef = coworkerRef.childByAutoId()
        let newCoworkerItem = [
            "userId":   uid,
            "name":     name,
            "email":    email
        ]
        newCoworkerRef.setValue(newCoworkerItem)
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
    
    func showHidePassword (_ sender: Any) {
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
