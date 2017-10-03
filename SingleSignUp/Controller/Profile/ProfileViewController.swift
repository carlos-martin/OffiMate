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
    case profile = 0
    case password
}

enum ProfileCell: Int {
    case image = 0
    case name
    case email
}

class ProfileViewController: UIViewController {
    
    var isHidden:   Bool = true
    var isEditMode: Bool = false
    
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
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let currentSection: ProfileSection = ProfileSection(rawValue: section) {
            switch currentSection {
            case .profile:
                return 3
            case .password:
                return 1
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = indexPath.section
        let row = indexPath.row
        
        if section == ProfileSection.profile.rawValue && row == ProfileCell.image.rawValue {
            return UITableViewAutomaticDimension
        } else {
            return 44.0
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = indexPath.section
        let row = indexPath.row
        
        if section == ProfileSection.profile.rawValue && row == ProfileCell.image.rawValue {
            return UITableViewAutomaticDimension
        } else {
            return 44.0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let currentSection: ProfileSection = ProfileSection(rawValue: section) {
            switch currentSection {
            case .profile:
                return nil
            case .password:
                return "Password"
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
            case .password:
                return 18.0
            }
        } else {
            return 0.1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 18.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let currentSection: ProfileSection = ProfileSection(rawValue: indexPath.section) {
            switch currentSection {
            case .profile:
                let currentRow: ProfileCell = ProfileCell(rawValue: indexPath.row)!
                switch currentRow {
                case .image:
                    let cell = self.tableView.dequeueReusableCell(withIdentifier: "profileCell", for: indexPath) as! PictureViewCell
                    cell.profileImage.layer.cornerRadius = cell.profileImage.frame.size.width / 2
                    cell.profileImage.layer.borderWidth = 0.5
                    cell.profileImage.layer.borderColor = Tools.separator.cgColor
                    cell.profileImage.backgroundColor = Tools.backgrounsColors.first!
                    cell.profileImage.clipsToBounds = true
                    return cell
                case .name:
                    let cell = self.tableView.dequeueReusableCell(withIdentifier: "informationCell", for: indexPath) as! InformationViewCell
                    cell.textField.text = CurrentUser.name
                    cell.textField.font = UIFont(name: cell.textField.font!.fontName, size: 22)
                    return cell
                case .email:
                    let cell = self.tableView.dequeueReusableCell(withIdentifier: "informationCell", for: indexPath) as! InformationViewCell
                    cell.textField.text = CurrentUser.email
                    return cell
                }
            case .password:
                let cell = self.tableView.dequeueReusableCell(withIdentifier: "passwordCell", for: indexPath) as! PasswordViewCell
                cell.passwordTextField.text = CurrentUser.password
                cell.showHideButton.addTarget(self, action: #selector(showHidePassword(_:)), for: UIControlEvents.touchUpInside)
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
}
