//
//  ProfileViewController.swift
//  SingleSignUp
//
//  Created by Carlos Martin on 29/08/17.
//  Copyright © 2017 Carlos Martin. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth

enum ProfileSection: Int {
    case profile = 0
    case office
    case password
    case inbox
    case logout
}

enum ProfileInfoRow: Int {
    case image = 0
    case name
    case email
}

class ProfileViewController: UIViewController {
    
    var isHidden:   Bool = true
    var isEditMode: Bool = false
    
    var hasUnread: Bool = false {
        didSet { self.tableView.reloadData() }
    }
    
    //MARK: IBOutlet
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var cancelBarButtonItem: UIBarButtonItem!
    
    //MARK: IBAction
    @IBAction func cancelActionButton(_ sender: Any) {
        Tools.goToMain(vc: self)
    }
    
    @IBAction func editActionButton(_ sender: Any) {
        self.editAction()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Tools.unreadBoostCard(uid: CurrentUser.user!.uid) { (unread: Bool) in
            self.hasUnread = unread
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func logoutAction() {
        do {
            try Auth.auth().signOut()
            CurrentUser.localClean()
            Tools.goToOnboard(vc: self)
        } catch {
            Alert.showFailiureAlert(message: "Ops! Something goes wrong!")
        }
        
    }
    
    func editAction(name: String?=nil) {
        if self.isEditMode {
            self.tableView.isScrollEnabled = true
            self.view.endEditing(true)
            self.editBarButtonItem.title = "Edit"
            self.cancelBarButtonItem.isEnabled = true
            if let newname = name {
                self.updateName(name: newname)
            }
            
        } else {
            self.tableView.isScrollEnabled = false
            self.view.endEditing(false)
            self.editBarButtonItem.title = "Cancel"
            self.cancelBarButtonItem.isEnabled = false
        }
        
        self.isEditMode = (self.isEditMode ? false : true)
        self.updateTableView()
    }
    
    func updateName(name: String) {
        do {
            try CurrentUser.setName(name: name)
            try CurrentUser.localSave()
            Database.database().reference().child("coworkers").child(CurrentUser.coworkerId!).child("name").setValue(name)
        } catch {
            Alert.showFailiureAlert(message: "Oops! Something goes wrong!")
        }
    }
    
    func updateTableView() {
        var indexSet = IndexSet()
        indexSet.insert(ProfileSection.password.rawValue)
        indexSet.insert(ProfileSection.inbox.rawValue)
        indexSet.insert(ProfileSection.logout.rawValue)
        self.tableView.reloadSections(indexSet, with: .fade)
        
        let indexParhArray = [
            IndexPath(row: ProfileInfoRow.name.rawValue, section: ProfileSection.profile.rawValue),
            IndexPath(row: 0, section: ProfileSection.office.rawValue)]
        self.tableView.reloadRows(at: indexParhArray, with: .fade)
        //self.tableView.reloadData()
    }
    
}

//MARK: - TableView
extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let currentSection: ProfileSection = ProfileSection(rawValue: section) {
            switch currentSection {
            case .profile:
                return 3
            case .office:
                return 1
            case .logout, .inbox, .password:
                return (self.isEditMode ? 0 : 1)
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let section: ProfileSection = ProfileSection(rawValue: indexPath.section)!
        switch section {
        case .profile:
            let row = ProfileInfoRow(rawValue: indexPath.row)
            if row == .image {
                return UITableViewAutomaticDimension
            } else {
                return 44.0
            }
        case .office:
            return (self.isEditMode ? 70.0 : 44.0)
        default:
            return 44.0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section: ProfileSection = ProfileSection(rawValue: indexPath.section)!
        switch section {
        case .profile:
            let row = ProfileInfoRow(rawValue: indexPath.row)
            if row == .image {
                return UITableViewAutomaticDimension
            } else {
                return 44.0
            }
        case .office:
            return (self.isEditMode ? 70.0 : 44.0)
        default:
            return 44.0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let currentSection: ProfileSection = ProfileSection(rawValue: section) {
            switch currentSection {
            case .profile, .logout, .inbox:
                return nil
            case .password:
                return (self.isEditMode ? nil : "Password")
            case .office:
                return "Office"
            }
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let currentSection: ProfileSection = ProfileSection(rawValue: section) {
            switch currentSection {
            case .profile:
                return 0.1
            case .password, .office, .logout, .inbox:
                return UITableViewAutomaticDimension
            }
        } else {
            return 0.1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 18.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section: ProfileSection = ProfileSection(rawValue: indexPath.section)!
        switch section {
        case .inbox:
            self.tableView.deselectRow(at: indexPath, animated: true)
            performSegue(withIdentifier: "showInbox", sender: indexPath)
        case .logout:
            self.logoutAction()
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let currentSection: ProfileSection = ProfileSection(rawValue: indexPath.section) {
            switch currentSection {
            case .profile:
                let currentRow: ProfileInfoRow = ProfileInfoRow(rawValue: indexPath.row)!
                switch currentRow {
                case .image:
                    let cell = self.tableView.dequeueReusableCell(withIdentifier: "profileCell", for: indexPath) as! PictureViewCell
                    cell.selectionStyle = .none
                    cell.profileImage.layer.cornerRadius = cell.profileImage.frame.size.width / 2
                    cell.profileImage.layer.borderWidth = 0.5
                    cell.profileImage.layer.borderColor = Tools.separator.cgColor
                    cell.profileImage.backgroundColor = Tools.getColor(id: CurrentUser.user!.uid)
                    cell.profileImage.clipsToBounds = true
                    return cell
                case .name:
                    let cell = self.tableView.dequeueReusableCell(withIdentifier: "informationCell", for: indexPath) as! InformationViewCell
                    cell.selectionStyle = .none
                    cell.textField.text = CurrentUser.name
                    cell.textField.delegate = self
                    
                    if self.isEditMode {
                        cell.textField.font = UIFont(name: ".SFUIText-Italic", size: 22)
                        cell.textField.borderStyle = UITextBorderStyle.roundedRect
                        cell.textField.backgroundColor = Tools.grayTextField
                        cell.textField.isEnabled = true
                    } else {
                        cell.textField.font = UIFont(name: ".SFUIText", size: 22)
                        cell.textField.borderStyle = UITextBorderStyle.none
                        cell.textField.backgroundColor = UIColor.white
                        cell.textField.isEnabled = false
                    }
                    
                    return cell
                case .email:
                    let cell = self.tableView.dequeueReusableCell(withIdentifier: "informationCell", for: indexPath) as! InformationViewCell
                    cell.selectionStyle = .none
                    cell.textField.text = CurrentUser.email
                    return cell
                }
            case .office:
                if self.isEditMode {
                    let cell = self.tableView.dequeueReusableCell(withIdentifier: "officePickerCell", for: indexPath) as! OfficePickerViewCell
                    cell.officePickerView.delegate = self
                    cell.officePickerView.dataSource = self
                    let index = CurrentUser.allOffices.index(of: CurrentUser.office) ?? 0
                    cell.officePickerView.selectRow(index, inComponent: 0, animated: true)
                    return cell
                } else {
                    let cell = self.tableView.dequeueReusableCell(withIdentifier: "optionsCell", for: indexPath) as! OptionsViewCell
                    cell.selectionStyle = .none
                    cell.arrowImage.isHidden = true
                    cell.unreadImage.isHidden = true
                    cell.optionImage.image = UIImage(named: "office")
                    cell.optionImage.backgroundColor = UIColor.white
                    cell.optionLabel.text = CurrentUser.office.name
                    return cell
                }
            case .password:
                let cell = self.tableView.dequeueReusableCell(withIdentifier: "passwordCell", for: indexPath) as! PasswordViewCell
                cell.selectionStyle = .none
                cell.passwordTextField.text = CurrentUser.password
                cell.showHideButton.addTarget(self, action: #selector(showHidePassword(_:)), for: UIControlEvents.touchUpInside)
                return cell
                
            case .inbox:
                let cell = self.tableView.dequeueReusableCell(withIdentifier: "optionsCell", for: indexPath) as! OptionsViewCell
                cell.selectionStyle = .gray
                cell.arrowImage.isHidden = false
                cell.unreadImage.isHidden = (self.hasUnread ? false : true)
                cell.optionImage.image = UIImage(named: "inbox")
                cell.optionImage.backgroundColor = UIColor.white
                cell.optionLabel.text = "Inbox"
                return cell
                
            case .logout:
                let cell = self.tableView.dequeueReusableCell(withIdentifier: "optionsCell", for: indexPath) as! OptionsViewCell
                cell.selectionStyle = .gray
                cell.arrowImage.isHidden = true
                cell.unreadImage.isHidden = true
                cell.optionImage.image = UIImage(named: "logout")
                cell.optionImage.backgroundColor = Tools.redLogout
                cell.optionImage.layer.cornerRadius = 4
                cell.optionLabel.text = "Logout"
                return cell
            }
        } else {
            return UITableViewCell()
        }
    }
    
    func showHidePassword (_ sender: Any) {
        let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: ProfileSection.password.rawValue)) as! PasswordViewCell
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
    
    //MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { //showInbox
        if segue.identifier == "showInbox" {
            if let indexPath = sender as? IndexPath {
                if indexPath.section == ProfileSection.inbox.rawValue {
                    var controller: InboxViewController
                    if let navigationController = segue.destination as? UINavigationController {
                        controller = navigationController.topViewController as! InboxViewController
                    } else {
                        controller = segue.destination as! InboxViewController
                    }
                    controller.navigationItem.title = "Inbox"
                }
            }
        }
    }
}

//MARK: - UIPickerView
extension ProfileViewController: UIPickerViewDelegate, UIPickerViewDataSource {    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return CurrentUser.allOffices.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return CurrentUser.allOffices[row].name
    }
}

//MARK: - UITextField
extension ProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        var result: Bool = false
        if let name = textField.text {
            if name.isEmpty {
                let message = "Oops! Your name cannot be empty!"
                Alert.showFailiureAlert(message: message, handler: { (_) in
                    Tools.textFieldErrorAnimation(textField: textField)
                })
            } else if name == CurrentUser.name! {
                self.editAction()
                result = true
            } else {
                self.editAction(name: name)
                result = true
            }
        }
        return result
    }
}
