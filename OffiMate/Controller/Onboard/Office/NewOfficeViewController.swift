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
    
    @IBOutlet weak var saveBarButtonItem: UIBarButtonItem!

    @IBAction func saveBarButtonAction(_ sender: Any) {
        self.saveActionButton()
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
    }
    
    func saveActionButton() {
        self.spinner = SpinnerLoader(view: self.view, alpha: 0.1)
        
        let nameCell = self.tableView.cellForRow(at: IndexPath(row: 0, section: NewOfficeSection.name.rawValue)) as! NewOfficeNameViewCell
        let codeCell = self.tableView.cellForRow(at: IndexPath(row: 0, section: NewOfficeSection.code.rawValue)) as! NewOfficeNameViewCell
        
        if nameCell.nameLabel.isEditing {
            nameCell.nameLabel.endEditing(true)
        }
        
        if codeCell.nameLabel.isEditing {
           codeCell.nameLabel.endEditing(true)
        }
        
        if self.readyToSave(nameCell: nameCell, codeCell: codeCell) {
            
            self.spinner.start()
            self.saveBarButtonItem.isEnabled = false
            
            Auth.auth().signIn(withEmail: ADMIN_NAME, password: ADMIN_PASS, completion: { (user: User?, error: Error?) in
                
                self.spinner.stop()
                self.saveBarButtonItem.isEnabled = true
                
                if let _ = error {
                    let title = "Error"
                    let message = "Oops! Something goes wrong. Try again later."
                    Alert.showFailiureAlert(title: title, message: message, handler: nil)
                } else {
                    let name = nameCell.nameLabel!.text!
                    let id = Tools.createOffice(name: name)
                    
                    let office = Office(id: id, name: name)
                    print(office)
                    
                    self.goBack()
                }
            })
        }
    }
    
    func readyToSave (nameCell: NewOfficeNameViewCell, codeCell: NewOfficeNameViewCell) -> Bool {
        var counter = 0
        if !nameCell.nameLabel.text!.isEmpty {
            counter += 1
        } else {
            let title = "Error"
            let message = "The office name field cannot be empty"
            Alert.showFailiureAlert(title: title, message: message, handler: { (_) in
                Tools.cellViewErrorAnimation(cell: nameCell)
            })
        }
        
        if codeCell.nameLabel.text! == SIGMA_CODE {
            counter += 1
        } else {
            let title = "Validating Code Error"
            let message = "Oops! Something goes wrong with your validation code. Check it again or try to get new one."
            Alert.showFailiureAlert(title: title, message: message, handler: { (_) in
                Tools.cellViewErrorAnimation(cell: codeCell)
            })
        }
        return (counter == 2 ? true : false)
    }
    
    func goBack() {
        do {
            try Auth.auth().signOut()
            print("[NewOfficeViewController] Signed Out!")
        } catch {
            print("[NewOfficeViewController] Error Signing Out!")
        }
        self.navigationController?.popToRootViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
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
            self.saveActionButton()
        }
        return true
    }
}
