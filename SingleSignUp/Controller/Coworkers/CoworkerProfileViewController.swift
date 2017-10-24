//
//  CoworkerProfileViewController.swift
//  SingleSignUp
//
//  Created by Carlos Martin on 03/10/2017.
//  Copyright © 2017 Carlos Martin. All rights reserved.
//

import UIKit

enum CoworkerSection: Int {
    case profile = 0
    case options
}

enum CoworkerOptions: Int {
    case boost = 0
}

enum CoworkerProfile: Int {
    case data = 0
    case office
}

class CoworkerProfileViewController: UITableViewController {

    var coworker: Coworker?
    var unwindSegue: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func initUI () {
        let backButton = UIBarButtonItem(
            title: "Go Back",
            style: .plain,
            target: self,
            action: #selector(goBackAction))
        self.navigationItem.leftBarButtonItem = backButton
    }
    
    func goBackAction() {
        print(unwindSegue!)
        self.performSegue(withIdentifier: unwindSegue!, sender: self)
    }

    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showBoostCard" { 
            if let indexPath = sender as? IndexPath {
                if indexPath.section == CoworkerSection.options.rawValue && indexPath.row == CoworkerOptions.boost.rawValue {
                    var controller: NewBoostCardViewController
                    if let navigationController = segue.destination as? UINavigationController {
                        controller = navigationController.topViewController as! NewBoostCardViewController
                    } else {
                        controller = segue.destination as! NewBoostCardViewController
                    }
                    controller.coworker = self.coworker
                }
            }
        }
    }
    
    @IBAction func unwindToCoworkerProfile(segue: UIStoryboardSegue) {}
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let currentSection = CoworkerSection(rawValue: section)!
        switch currentSection {
        case .profile:
            return 2
        case .options:
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section: CoworkerSection = CoworkerSection(rawValue: indexPath.section)!
        switch section {
        case .profile:
            break
        case .options:
            let row: CoworkerOptions = CoworkerOptions(rawValue: indexPath.row)!
            if row == .boost {
                tableView.deselectRow(at: indexPath, animated: true)
                performSegue(withIdentifier: "showBoostCard", sender: indexPath)
            }
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section: CoworkerSection = CoworkerSection(rawValue: indexPath.section)!
        switch section {
        case .profile:
            
            let row: CoworkerProfile = CoworkerProfile(rawValue: indexPath.row)!
            switch row {
            case .data:
                let cell = tableView.dequeueReusableCell(withIdentifier: "coworkerProfileCell", for: indexPath) as! CoworkerProfileViewCell
                cell.selectionStyle = .none
                cell.coworkerNameLabel.text  = self.coworker?.name
                cell.coworkerEmailLabel.text = self.coworker?.email
                cell.coworkerPictureProfile.layer.cornerRadius = cell.coworkerPictureProfile.frame.size.width / 2
                cell.coworkerPictureProfile.layer.borderWidth = 1.0
                cell.coworkerPictureProfile.layer.borderColor = Tools.separator.cgColor
                cell.coworkerPictureProfile.backgroundColor = Tools.getColor(id: self.coworker!.uid)
                cell.coworkerPictureProfile.clipsToBounds = true
                return cell
            case .office:
                let cell = tableView.dequeueReusableCell(withIdentifier: "coworkerOptionCell", for: indexPath) as! CoworkerOptionViewCell
                cell.selectionStyle = .none
                cell.iconImage.image = UIImage(named: "office")
                cell.actionLaben.text = self.coworker?.office.name
                cell.arrowImage.isHidden = true
                return cell
            }
            
            
        case .options:
            let cell = tableView.dequeueReusableCell(withIdentifier: "coworkerOptionCell", for: indexPath) as! CoworkerOptionViewCell
            cell.selectionStyle = .gray
            cell.iconImage.image = UIImage(named: "boost")
            cell.actionLaben.text = "Send a Boost Card"
            cell.arrowImage.isHidden = false
            return cell
        }
    }

}
