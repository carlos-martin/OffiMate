//
//  EmailViewController.swift
//  SingleSignUp
//
//  Created by Carlos Martin on 23/08/17.
//  Copyright © 2017 Carlos Martin. All rights reserved.
//

import Foundation
import UIKit

class EmailViewController: UIViewController {
    
    var username: String?
    var email:    String?
    
    //MARK: IBOutlet
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nextBarButtonItem: UIBarButtonItem!
    
    //MARK: IBAction
    @IBAction func nextActionButton(_ sender: Any) {
        self.nextAction()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.tableView.reloadData()
        self.initUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func initUI(){
        if Tools.iOS() <= 10 {
            self.nextBarButtonItem.image = UIImage(named: "nextOld")
        }
        (self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! EmailSignUpViewCell).emailTextField.becomeFirstResponder()
    }
    
    //MARK: Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toOffice", let nextScene = segue.destination as? OfficeViewController {
            nextScene.username = self.username
            nextScene.email = self.email
        }
    }
    
    func nextAction() {
        if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) {
            if self.readyToMove(cell: cell) {
                self.email = (cell as! EmailSignUpViewCell).emailTextField.text!
                self.moveToOffice()
            } else {
                let title = "Validation Email Error"
                let message = "Your email must have one of this two domains: sigma.se or sigmatechnology.se"
                Alert.showFailiureAlert(title: title, message: message)
                Tools.cellViewErrorAnimation(cell: cell)
            }
        }
    }
    
    func readyToMove (cell: UITableViewCell) -> Bool {
        let isReady: Bool
        if let textField = (cell as! EmailSignUpViewCell).emailTextField {
            isReady = Tools.validateSigmaEmail(email: textField)
        } else {
            isReady = false
        }
        return isReady
    }
    
    func moveToOffice() {
        self.view.endEditing(true)
        performSegue(withIdentifier: "toOffice", sender: nil)
    }
}

//MARK: - TableView
extension EmailViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "What's your Sigma e-mail?"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "emailSignUpCell", for: indexPath) as! EmailSignUpViewCell
        cell.emailTextField.delegate = self
        cell.emailTextField.placeholder = "Enter your email..."
        cell.emailTextField.tag = indexPath.row
        return cell
    }
    
    //Dismissing Keyboard
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.onDrag
    }
}

//MARK: - TextField
extension EmailViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.nextAction()
        return true
    }
}
