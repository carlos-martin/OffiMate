//
//  PasswordViewController.swift
//  SingleSignUp
//
//  Created by Carlos Martin on 23/08/17.
//  Copyright © 2017 Carlos Martin. All rights reserved.
//

import Foundation
import UIKit
import AWSCognitoIdentityProvider

class PasswordViewController: UIViewController {
    
    var pool: AWSCognitoIdentityUserPool?
    
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
        self.initAWS()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func startTextField(){
        (self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! PasswordSignUpViewCell).passwordTextField.becomeFirstResponder()
    }
    
    private func initAWS() {
        self.pool = AWSCognitoIdentityUserPool.init(forKey: AWSCognitoUserPoolsSignInProviderKey)
    }
    
    //MARK: Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toConfirm", let nextScene = segue.destination as? ConfirmViewController {
            nextScene.user =     self.pool?.getUser(self.email!)
            nextScene.username = self.username
            nextScene.email =    self.email
            nextScene.password = self.password
        }
    }
    
    func saveAction (_ sender: Any?=nil) {
        if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) {
            if self.readyToSave(cell: cell) {
                self.password = (cell as! PasswordSignUpViewCell).passwordTextField.text!
                
                var attributes = [AWSCognitoIdentityUserAttributeType]()
                
                let aws_name = AWSCognitoIdentityUserAttributeType()
                aws_name?.name = "name"
                aws_name?.value = self.username
                attributes.append(aws_name!)
                
                let aws_email = AWSCognitoIdentityUserAttributeType()
                aws_email?.name = "email"
                aws_email?.value = self.email
                attributes.append(aws_email!)
                
                self.pool?.signUp(
                    self.email!,
                    password: self.password!,
                    userAttributes: attributes,
                    validationData: nil).continueWith {[weak self] (task) -> Any? in
                        //TODO
                        guard let strongSelf = self else { return nil }
                        DispatchQueue.main.async(execute: { 
                            if let error = task.error as? NSError {
                                Alert.showFailiureAlert(message: error.userInfo["message"] as! String, handler: { (_) in
                                    //TODO something or not
                                })
                            } else if let result = task.result {
                                if result.user.confirmedStatus != AWSCognitoIdentityUserStatus.confirmed {
                                    strongSelf.performSegue(withIdentifier: "toConfirm", sender: sender)
                                } else {
                                    let _ = strongSelf.navigationController?.popToRootViewController(animated: true)
                                }
                            }
                        })
                        return nil
                }
                
                do {
                    try CurrentUser.setData(name: self.username!, email: self.email!, password: self.password!)
                    try CurrentUser.localSave()
                    Tools.goToMain(vc: self)
                } catch {
                    Alert.showFailiureAlert(message: "Ops! Something goes wrong", handler: { (_) in
                        Tools.goToOnboard(vc: self) //TODO: change it using unwind  
                    })
                }
                
            } else {
                Tools.cellViewErrorAnimation(cell: cell)
            }
        }
    }
    
    func readyToSave(cell: UITableViewCell) -> Bool {
        let isReady: Bool
        if let textField = (cell as! PasswordSignUpViewCell).passwordTextField {
            isReady = Tools.validateSingelPassword(pass: textField)
        } else {
            isReady = false
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
