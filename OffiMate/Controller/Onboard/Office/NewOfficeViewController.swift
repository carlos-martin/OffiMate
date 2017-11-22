//
//  NewOfficeViewController.swift
//  SingleSignUp
//
//  Created by Carlos Martin on 23/10/2017.
//  Copyright © 2017 Carlos Martin. All rights reserved.
//

import UIKit
import MessageUI
import FirebaseAuth

enum NewOfficeSection: Int {
    case name = 0
    case code
}

class NewOfficeViewController: UITableViewController, MFMailComposeViewControllerDelegate {
    
    var spinner: SpinnerLoader!
    
    var unwindSegue: String?
    
    @IBOutlet weak var saveBarButtonItem: UIBarButtonItem!

    @IBAction func saveBarButtonAction(_ sender: Any) {
        self.saveAction()
    }
    @IBAction func mailtoButtonAction(_ sender: Any) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["Carlos.Martin@sigmatechnology.se"])
            mail.setSubject("OffiMate: I would like to create a new Office!")
            present(mail, animated: true, completion: nil)
        } else {
            let title = "Mail Error"
            let message = "Oops! Unexpected error appears trying to prepare the email."
            Alert.showAlertOptions(title: title, message: message)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func initUI () {
        self.spinner = SpinnerLoader(view: self.view, alpha: 0.1)
        
        let backButton = UIBarButtonItem(
            image: UIImage(named: "close"),
            style: .plain,
            target: self,
            action: #selector(closeAction))
        
        self.navigationItem.leftBarButtonItem = backButton
        
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = true
        } else {
            // Fallback on earlier versions
        }
    }
    
    @objc func closeAction() {
        self.performSegue(withIdentifier: self.unwindSegue!, sender: self)
    }
    
    func saveAction() {
        let nameCell = self.tableView.cellForRow(at: IndexPath(row: 0, section: NewOfficeSection.name.rawValue)) as! NewOfficeNameViewCell
        let codeCell = self.tableView.cellForRow(at: IndexPath(row: 0, section: NewOfficeSection.code.rawValue)) as! NewOfficeNameViewCell
        
        let name = nameCell.nameLabel.text!
        let code = codeCell.nameLabel.text!
        
        self.spinner = SpinnerLoader(view: self.view, alpha: 0.1)
        if nameCell.nameLabel.isEditing {
            nameCell.nameLabel.endEditing(true)
        }
        if codeCell.nameLabel.isEditing {
            codeCell.nameLabel.endEditing(true)
        }
        
        if name.isEmpty {
            let title = "Error"
            let message = "The office name field cannot be empty"
            Alert.showFailiureAlert(title: title, message: message, handler: { (_) in
                Tools.cellViewErrorAnimation(cell: nameCell)
            })
        } else if code.isEmpty {
            let title = "Error"
            let message = "The code field cannot be empty"
            Alert.showFailiureAlert(title: title, message: message, handler: { (_) in
                Tools.cellViewErrorAnimation(cell: codeCell)
            })
        } else {
            self.spinner.start()
            self.saveBarButtonItem.isEnabled = false
            Auth.auth().signIn(withEmail: ADMIN_NAME, password: ADMIN_PASS, completion: { (user: User?, error: Error?) in
                if let _ = error {
                    self.spinner.stop()
                    self.saveBarButtonItem.isEnabled = true
                    let title = "Error"
                    let message = "Oops! Something goes wrong. Try again later."
                    Alert.showFailiureAlert(title: title, message: message, handler: nil)
                } else {
                    Tools.validateGroupCode(code: code, completion: { (valid: Bool) in
                        self.spinner.stop()
                        self.saveBarButtonItem.isEnabled = true
                        if !valid {
                            let title = "Validating Code Error"
                            let message = "Oops! Something goes wrong with your validation code. Check it again or try to get new one."
                            Alert.showFailiureAlert(title: title, message: message, handler: { (_) in
                                Tools.cellViewErrorAnimation(cell: codeCell)
                            })
                        } else {
                            let _ = Tools.createOffice(name: name)
                            let title = "Completed Process"
                            let message = "You have created a new office with the name \(name) at the system successfully."
                            Alert.showFailiureAlert(title: title, message: message, handler: { (_) in
                                self.goBack()
                            })
                        }
                    })
                }
            })
        }
    }
    
    func goBack() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("[NewOfficeViewController] Error Signing Out!")
        }
        self.closeAction()
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let currentSection = NewOfficeSection(rawValue: section)!
        switch currentSection {
        case .name:
            return "What's your office name?"
        case .code:
            return "What's your validation code?"
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentSection = NewOfficeSection(rawValue: indexPath.section)!
        let cell = tableView.dequeueReusableCell(withIdentifier: "newOfficeNameCell", for: indexPath) as! NewOfficeNameViewCell
        switch currentSection {
        case .name:
            cell.nameLabel.delegate = self
            cell.nameLabel.placeholder = "Enter your office name..."
            cell.nameLabel.tag = indexPath.section
            cell.nameLabel.becomeFirstResponder()
        case .code:
            cell.nameLabel.delegate = self
            cell.nameLabel.placeholder = "Enter your validation code..."
            cell.nameLabel.tag = indexPath.section
        }
        return cell
    }
    
    // MARK: - MFMail Compose
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    //Dismissing Keyboard
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.onDrag
    }

}

extension NewOfficeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let section = NewOfficeSection(rawValue: textField.tag)!
        switch section {
        case .name:
            let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: NewOfficeSection.code.rawValue)) as! NewOfficeNameViewCell
            cell.nameLabel.becomeFirstResponder()
        case .code:
            self.saveAction()
        }
        return true
    }
}
