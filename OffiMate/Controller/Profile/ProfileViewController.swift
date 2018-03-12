//
//  ProfileViewController.swift
//  OffiMate
//
//  Created by Carlos Martin on 20/11/2017.
//  Copyright © 2017 Carlos Martin. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth

enum ProfileSection: Int {
    case userprofile = 0
    case userdata
    case boostcard
    case newoffice
    case logout
    
    static var count: Int { return ProfileSection.logout.rawValue + 1 }
}

enum UserdataRow: Int {
    case office = 0
    case password
}

enum BoostcardRow: Int {
    case inbox = 0
    case sent
}

class ProfileViewController: UITableViewController {
    
    var isHidden:   Bool = true
    var isEditMode: Bool = false
    
    var hasUnread: Bool = false {
        didSet { self.tableView.reloadData() }
    }
    
    // MARK: Data to be save
    var name: String?
    var office: Office?
    
    // MARK: IBOutlet
    @IBOutlet weak var editBarButtonItem:       UIBarButtonItem!
    @IBOutlet weak var gobackBarButtonItem:     UIBarButtonItem!
    
    // MARK: IBAction
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
        if !Tools.isInternetAvailable() {
            Tools.goToWaitingRoom(vc: self)
        }
        Tools.unreadBoostCard(uid: CurrentUser.user!.uid) { (unread: Bool) in
            self.hasUnread = unread
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UI Actions
    func initUI() {
        self.tableView.isScrollEnabled = true
        
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = true
        } else {
            // Fallback on earlier versions
        }
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
            self.editBarButtonItem.image = UIImage(named: "edit")
            self.gobackBarButtonItem.isEnabled = true
            
            if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: ProfileSection.userprofile.rawValue)) {
                let profileCell = cell as! ProfileViewCell
                profileCell.nameTextField.font = UIFont(name: ".SFUIText", size: 22)
                profileCell.nameTextField.backgroundColor = UIColor.white
                profileCell.nameTextField.layer.borderWidth = .leastNonzeroMagnitude
                profileCell.nameTextField.layer.borderColor = UIColor.white.cgColor
                profileCell.nameTextField.isEnabled = false
                
                let textFieldName = profileCell.nameTextField.text
                
                if self.name == nil {
                    self.name = textFieldName
                } else if self.name != textFieldName {
                    self.name = textFieldName
                }
            }
            self.saveAction()
        } else {
            self.tableView.isScrollEnabled = false
            self.view.endEditing(false)
            self.editBarButtonItem.image = UIImage(named: "save")
            self.gobackBarButtonItem.isEnabled = false
            if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: ProfileSection.userprofile.rawValue)) {
                let profileCell = cell as! ProfileViewCell
                profileCell.nameTextField.font = UIFont(name: ".SFUIText-Italic", size: 22)
                profileCell.nameTextField.backgroundColor = UIColor.groupTableViewBackground.withAlphaComponent(0.5)
                profileCell.nameTextField.layer.borderWidth = 0.5
                profileCell.nameTextField.layer.borderColor = Tools.separator.cgColor
                profileCell.nameTextField.isEnabled = true
                profileCell.nameTextField.layer.cornerRadius = 12
            }
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

    // MARK: - Table view data source
    
    func updateTableView() {
        var indexSet = IndexSet()
        indexSet.insert(ProfileSection.boostcard.rawValue)
        indexSet.insert(ProfileSection.logout.rawValue)
        indexSet.insert(ProfileSection.userdata.rawValue)
        indexSet.insert(ProfileSection.newoffice.rawValue)
        self.tableView.reloadSections(indexSet, with: .fade)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return ProfileSection.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let currentSection: ProfileSection = ProfileSection(rawValue: section) {
            switch currentSection {
            case .userprofile:
                return 1
            case .userdata:
                return (self.isEditMode ? 1 : 2)
            case .boostcard:
                return (self.isEditMode ? 0 : 2)
            case .newoffice:
                return (self.isEditMode ? 0 : 1)
            case .logout:
                return (self.isEditMode ? 0 : 1)
            }
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section: ProfileSection = ProfileSection(rawValue: indexPath.section)!
        switch section {
        case .userprofile:
            return 155.0
        case .userdata:
            let row: UserdataRow = UserdataRow(rawValue: indexPath.row)!
            switch row {
            case .office:
                return (self.isEditMode ? 70.0 : 44.0)
            case .password:
                return 44.0
            }
            
        default:
            return 44.0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let currentSection: ProfileSection = ProfileSection(rawValue: section)!
        switch currentSection {
        case .boostcard:
            return (self.isEditMode ? nil : "Boostcard")
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let currentSection: ProfileSection = ProfileSection(rawValue: section)!
        switch currentSection {
        case .userprofile:
            return CGFloat.leastNonzeroMagnitude
        default:
            return UITableViewAutomaticDimension
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section: ProfileSection = ProfileSection(rawValue: indexPath.section)!
        switch section {
        case .boostcard:
            self.tableView.deselectRow(at: indexPath, animated: true)
            performSegue(withIdentifier: "showInbox", sender: indexPath)
        case .logout:
            self.logoutAction()
        case .newoffice:
            self.toNewOffice()
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let currentSection: ProfileSection = ProfileSection(rawValue: indexPath.section) {
            switch currentSection {
            case .userprofile:
                let cell = self.tableView.dequeueReusableCell(withIdentifier: "profileCell", for: indexPath) as! ProfileViewCell
                
                cell.selectionStyle = .none
                
                //profileImage: UIImageView!
                cell.profileImage.layer.cornerRadius = cell.profileImage.frame.size.width / 2
                cell.profileImage.layer.borderWidth = 0.5
                cell.profileImage.layer.borderColor = Tools.separator.cgColor
                cell.profileImage.backgroundColor = Tools.getColor(id: CurrentUser.user!.uid)
                cell.profileImage.clipsToBounds = true
                
                //nameTextField: UITextField!
                cell.nameTextField.delegate = self
                cell.nameTextField.text = CurrentUser.name
                cell.nameTextField.borderStyle = .none
                
                //emailLabel: UILabel!
                cell.emailLabel.text = CurrentUser.email
                
                return cell
            case .userdata:
                let row: UserdataRow = UserdataRow(rawValue: indexPath.row)!
                switch row {
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
                }
            case .boostcard:
                let row = BoostcardRow(rawValue: indexPath.row)
                let cell = self.tableView.dequeueReusableCell(withIdentifier: "optionsCell", for: indexPath) as! OptionsViewCell
                cell.selectionStyle = .gray
                cell.arrowImage.isHidden = false
                if row == .inbox {
                    cell.unreadImage.isHidden = (self.hasUnread ? false : true)
                    cell.optionImage.image = UIImage(named: "inbox")
                    cell.optionLabel.text = "Inbox"
                } else {
                    cell.unreadImage.isHidden = true
                    cell.optionImage.image = UIImage(named: "sent")
                    cell.optionLabel.text = "Sent"
                }
                cell.optionImage.backgroundColor = UIColor.white
                return cell
            case .newoffice:
                let cell = self.tableView.dequeueReusableCell(withIdentifier: "optionsCell", for: indexPath) as! OptionsViewCell
                cell.selectionStyle = .gray
                cell.arrowImage.isHidden = true
                cell.unreadImage.isHidden = true
                cell.optionImage.image = UIImage(named: "new-office")
                cell.optionImage.backgroundColor = UIColor.white
                cell.optionLabel.text = "Create a new Office"
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

    
    @objc func showHidePassword (_ sender: Any) {
        let section = ProfileSection.userdata.rawValue
        let row = UserdataRow.password.rawValue
        let cell = self.tableView.cellForRow(at: IndexPath(row: row, section: section)) as! PasswordViewCell
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
                let section = ProfileSection(rawValue: indexPath.section)
                let row = BoostcardRow(rawValue: indexPath.row)
                
                if section == .boostcard && row == .inbox {
                    var controller: InboxViewController
                    if let navigationController = segue.destination as? UINavigationController {
                        controller = navigationController.topViewController as! InboxViewController
                    } else {
                        controller = segue.destination as! InboxViewController
                    }
                    controller.navigationItem.title = "Inbox"
                    controller.received = true
                }
                
                if section == .boostcard && row == .sent {
                    var controller: InboxViewController
                    if let navigationController = segue.destination as? UINavigationController {
                        controller = navigationController.topViewController as! InboxViewController
                    } else {
                        controller = segue.destination as! InboxViewController
                    }
                    controller.navigationItem.title = "Sent"
                    controller.received = false
                }
            }
        }
    }
    
    @IBAction func unwindToProfile(segue: UIStoryboardSegue) {}
    
    func toNewOffice () {
        if let navigationController = UIStoryboard(name: "Onboard", bundle: nil).instantiateViewController(withIdentifier: "NewOffice") as? UINavigationController {
            if let controller = navigationController.viewControllers.first as? NewOfficeViewController {
                controller.modalPresentationStyle = .fullScreen
                controller.modalTransitionStyle = .coverVertical
                controller.unwindSegue = "unwindSegueToProfile"
                self.present(navigationController, animated: true, completion: nil)
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
