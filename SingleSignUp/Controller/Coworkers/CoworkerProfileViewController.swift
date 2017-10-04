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

class CoworkerProfileViewController: UITableViewController {

    var coworker: Coworker?
    var index:    Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section: CoworkerSection = CoworkerSection(rawValue: indexPath.section)!
        let row: CoworkerOptions = CoworkerOptions(rawValue: indexPath.row)!
        if section == .options && row == .boost {
            tableView.deselectRow(at: indexPath, animated: true)
            performSegue(withIdentifier: "showBoostCard", sender: indexPath)
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section: CoworkerSection = CoworkerSection(rawValue: indexPath.section)!
        switch section {
        case .profile:
            let cell = tableView.dequeueReusableCell(withIdentifier: "coworkerProfileCell", for: indexPath) as! CoworkerProfileViewCell
            cell.selectionStyle = .none
            cell.coworkerNameLabel.text  = self.coworker?.name
            cell.coworkerEmailLabel.text = self.coworker?.email
            cell.coworkerPictureProfile.layer.cornerRadius = cell.coworkerPictureProfile.frame.size.width / 2
            cell.coworkerPictureProfile.layer.borderWidth = 1.0
            cell.coworkerPictureProfile.layer.borderColor = Tools.separator.cgColor
            cell.coworkerPictureProfile.backgroundColor = Tools.backgrounsColors[index!]
            cell.coworkerPictureProfile.clipsToBounds = true
            return cell
        case .options:
            let cell = tableView.dequeueReusableCell(withIdentifier: "coworkerOptionCell", for: indexPath) as! CoworkerOptionViewCell
            cell.selectionStyle = .gray
            cell.iconImage.image = UIImage(named: "boost")
            cell.actionLaben.text = "Send a Boost Card"
            return cell
        }
    }

}
