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
    case name = 0
    case mail
    case pass
}

class ProfileViewController: UIViewController {
    
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
        Tools.goToMain(vc: self)
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
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let currentSection: ProfileSection = ProfileSection(rawValue: section) {
            switch currentSection {
            case .name:
                return "Name:"
            case .mail:
                return "E-mail:"
            case .pass:
                return "Password:"
            }
        } else {
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let currentSection: ProfileSection = ProfileSection(rawValue: indexPath.section) {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "profileCell", for: indexPath) as! ProfileViewCell
            switch currentSection {
            case .name:
                cell.profileLabel.text = CurrentUser.name
            case .mail:
                cell.profileLabel.text = CurrentUser.email
            case .pass:
                cell.profileLabel.text = CurrentUser.password
            }
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
}
