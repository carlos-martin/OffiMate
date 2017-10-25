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
    case inbox
    case password
    case logout
}

enum ProfileInfoRow: Int {
    case image = 0
    case name
    case email
}

class ProfileViewController: UIViewController {
    
    var isHidden:   Bool = true
    var isEditMode: Bool = false {
        didSet {
            if isEditMode { self.saveButton?.animateUp(view: self.view) }
            else { self.saveButton?.animateDown(view: self.view) }
        }
    }
    
    var hasUnread: Bool = false {
        didSet { self.tableView.reloadData() }
    }
    
    //UI 
    var saveButton: FloatingButton?
    
    //To be save
    var name: String?
    var office: Office?
    
    //MARK: IBOutlet
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var gobackBarButtonItem: UIBarButtonItem!
    
    //MARK: IBAction
    @IBAction func gobackActionButton(_ sender: Any) {
        Tools.goToMain(vc: self)
    }
    
    @IBAction func editActionButton(_ sender: Any) {
        self.editAction()
    }
    
    //UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initUI()
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
    
    
    //MARK:- UI Actions
    func initUI() {
        self.saveButton = FloatingButton(
            view:       self.view,
            target:     nil,
            action:     #selector(saveAction),
            bgColor:    UIColor.white,
            tintColor:  UIColor.jsq_messageBubbleBlue(),
            image:      UIImage(named: "save")!)
        
        self.saveButton?.animateDown(view: self.view)
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
    
    func editAction() {
        if self.isEditMode {
            self.tableView.isScrollEnabled = true
            self.view.endEditing(true)
            //self.editBarButtonItem.title = "Edit"
            self.editBarButtonItem.image = UIImage(named: "edit")
            self.gobackBarButtonItem.isEnabled = true
        } else {
            self.tableView.isScrollEnabled = false
            self.view.endEditing(false)
            //self.editBarButtonItem.title = "Cancel"
            self.editBarButtonItem.image = UIImage(named: "close")
            self.gobackBarButtonItem.isEnabled = false
        }
        
        self.isEditMode = (self.isEditMode ? false : true)
        self.updateTableView()
    }
    
    func saveAction() {
        if let newName = self.name {
            if newName != CurrentUser.name! && !newName.isEmpty {
                self.updateName(name: newName)
            }
        }
        if let newOffice = self.office {
            if newOffice != CurrentUser.office {
                self.updateOffice(office: newOffice)
                CurrentUser.cleanChannels()
            }
        }
        self.editAction()
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
    
    func updateOffice(office: Office) {
        CurrentUser.office = office
        Database.database().reference().child("coworkers").child(CurrentUser.coworkerId!).child("officeId").setValue(office.id)
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
            let row = ProfileInfoRow(rawValue: indexPath.row)!
            switch row {
            case .image, .name:
                return UITableViewAutomaticDimension
            default:
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
            let row = ProfileInfoRow(rawValue: indexPath.row)!
            switch row {
            case .image, .name:
                return UITableViewAutomaticDimension
            default:
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
            case .profile, .logout:
                return nil
            case .office:
                return "Office"
            case .password:
                return (self.isEditMode ? nil : "Password")
            case .inbox:
                return (self.isEditMode ? nil : "Boost Card")
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
            case .password, .office, .inbox:
                return 30.0
            case .logout:
                return UITableViewAutomaticDimension
            }
        } else {
            return 0.1
        }
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
                        cell.textField.backgroundColor = UIColor.white//Tools.grayTextField
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
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.office = CurrentUser.allOffices[row]
    }
}

//MARK: - UITextField
extension ProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let name = textField.text {
            self.name = name
        }
        textField.endEditing(true)
        return true
    }
}
