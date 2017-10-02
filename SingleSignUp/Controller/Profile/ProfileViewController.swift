//
//  ProfileViewController.swift
//  SingleSignUp
//
//  Created by Carlos Martin on 29/08/17.
//  Copyright © 2017 Carlos Martin. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth

enum ProfileSection: Int {
    case edit = 0
    case name
    case mail
    case pass
}

class ProfileViewController: UIViewController {
    
    var isHidden:   Bool = true
    var isEditMode: Bool = false
    let notEditableCells: [IndexPath] = [
        IndexPath(row: 0, section: ProfileSection.mail.rawValue),
        IndexPath(row: 0, section: ProfileSection.pass.rawValue)
    ]
    
    //MARK: IBOutlet
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: IBAction
    @IBAction func cancelActionButton(_ sender: Any) {
        Tools.goToMain(vc: self)
    }
    
    @IBAction func logoutActionButton(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        } catch {
            Alert.showFailiureAlert(message: "Ops! Something goes wrong!")
        }
        CurrentUser.localClean()
        Tools.goToOnboard(vc: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let currentSection: ProfileSection = ProfileSection(rawValue: section) {
            switch currentSection {
            case .edit:
                return 1
            case .name:
                return 1
            case .mail:
                return (self.isEditMode ? 0 : 1)
            case .pass:
                return (self.isEditMode ? 0 : 1)
            }
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let currentSection: ProfileSection = ProfileSection(rawValue: section) {
            switch currentSection {
            case .edit:
                return nil
            case .name:
                return "Name:"
            case .mail:
                return (self.isEditMode ? nil : "E-mail:")
            case .pass:
                return (self.isEditMode ? nil : "Password:")
            }
        } else {
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let currentSection: ProfileSection = ProfileSection(rawValue: section) {
            switch currentSection {
            case .edit:
                return 0.1
            default:
                return 30.0
            }
        } else {
            return 0.1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let currentSection: ProfileSection = ProfileSection(rawValue: indexPath.section) {
            switch currentSection {
            case .edit:
                let cell = self.tableView.dequeueReusableCell(withIdentifier: "editCell", for: indexPath) as! EditViewCell
                if self.isEditMode {
                    cell.actionButton.setTitle("Save", for: UIControlState.normal)
                } else {
                    cell.actionButton.setTitle("Edit", for: UIControlState.normal)
                }
                cell.actionButton.addTarget(self, action: #selector(actionButtonPress(_:)), for: UIControlEvents.touchUpInside)
                return cell
            case .name:
                let cell = self.tableView.dequeueReusableCell(withIdentifier: "informationCell", for: indexPath) as! InformationViewCell
                cell.textField.text = CurrentUser.name
                cell.textField.delegate = self
                return cell
            case .mail:
                let cell = self.tableView.dequeueReusableCell(withIdentifier: "informationCell", for: indexPath) as! InformationViewCell
                cell.textField.text = CurrentUser.email
                return cell
            case .pass:
                let cell = self.tableView.dequeueReusableCell(withIdentifier: "passwordCell", for: indexPath) as! PasswordViewCell
                cell.passwordTextField.text = CurrentUser.password
                cell.showHideButton.addTarget(self, action: #selector(showHidePassword(_:)), for: UIControlEvents.touchUpInside)
                return cell
            }
            
        } else {
            return UITableViewCell()
        }
    }
    
    func actionButtonPress (_ sender: Any) {
        let sections = NSIndexSet(indexesIn: NSMakeRange(2, 2))
        let animation: UITableViewRowAnimation = UITableViewRowAnimation.automatic
        let editViewCell = self.tableView.cellForRow(at: IndexPath(row: 0, section: ProfileSection.edit.rawValue)) as! EditViewCell
        let nameViewCell = self.tableView.cellForRow(at: IndexPath(row: 0, section: ProfileSection.name.rawValue)) as! InformationViewCell
        if self.isEditMode {
            //do save stuff
            if let newName = nameViewCell.textField.text {
                if newName.isEmpty {
                    let message = "Name text field cannot be empty!"
                    Alert.showFailiureAlert(message: message, handler: { (_) in
                        Tools.cellViewErrorAnimation(cell: nameViewCell)
                    })
                    return
                } else if newName != CurrentUser.name {
                    do {
                        try CurrentUser.setName(name: newName)
                        try CurrentUser.localSave()
                    } catch {
                        Alert.showFailiureAlert(message: "Oops! Something goes wrong!")
                    }
                }
                
                self.isEditMode = false
                nameViewCell.textField.isEnabled = false
                editViewCell.actionButton.setTitle("Edit", for: UIControlState.normal)
                editViewCell.actionButton.setTitleColor(Tools.blueSystem, for: UIControlState.normal)
                self.tableView.reloadSections(sections as IndexSet, with: animation)
                
            } else {
                Alert.showFailiureAlert(message: "Oops! Something goes wrong!")
            }
        } else {
            //prepare for editing stuff
            self.isEditMode = true
            nameViewCell.textField.isEnabled = true
            nameViewCell.textField.becomeFirstResponder()
            editViewCell.actionButton.setTitle("Save", for: UIControlState.normal)
            editViewCell.actionButton.setTitleColor(UIColor.red, for: UIControlState.normal)
            self.tableView.reloadSections(sections as IndexSet, with: animation)
        }
    }
    
    func showHidePassword (_ sender: Any) {
        let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: ProfileSection.pass.rawValue)) as! PasswordViewCell
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
    
}

extension ProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.actionButtonPress(self)
        return true
    }
}
