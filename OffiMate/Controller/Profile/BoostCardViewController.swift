//
//  BoostCardViewController.swift
//  SingleSignUp
//
//  Created by Carlos Martin on 06/10/2017.
//  Copyright © 2017 Carlos Martin. All rights reserved.
//

import UIKit

enum BoostCardRow: Int {
    case header = 0
    case title
    case body
}

class BoostCardViewController: UITableViewController {
    
    var received: Bool?
    var boostCard: BoostCard?
    var name: String?
    var mail: String?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationItem.largeTitleDisplayMode = .never
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !Tools.isInternetAvailable() {
            Tools.goToWaitingRoom(vc: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Navigation
    @objc private func toCoworkerProfile () {
        let uid = (self.received! ? boostCard!.senderId : boostCard!.receiverId)
        Tools.fetchCoworker(uid: uid) { (_id: String?, _email: String?, _name: String?, _office: Office?) in
            if let id = _id, let email = _email, let name = _name, let office = _office {
                let coworker = Coworker(id: id, uid: uid, email: email, name: name, office: office)

                if let navigationController = UIStoryboard(name: "Coworkers", bundle: nil).instantiateViewController(withIdentifier: "CoworkerProfile") as? UINavigationController {
                    if let controller = navigationController.viewControllers.first as? CoworkerProfileViewController {
                        controller.modalPresentationStyle = .fullScreen
                        controller.modalTransitionStyle = .coverVertical
                        controller.coworker = coworker
                        controller.unwindSegue = "unwindSegueToBoostCard"
                        self.present(navigationController, animated: true, completion: nil)
                    }
                }
            }
            
        }
    }
    
    @IBAction func unwindToBoostCard(segue: UIStoryboardSegue) {}

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row: BoostCardRow = BoostCardRow(rawValue: indexPath.row)!
        switch row {
        case .header:
            let cell = tableView.dequeueReusableCell(withIdentifier: "boostcardHeaderCell", for: indexPath) as! BoostCardHeaderViewCell
            
            let header = (boostCard?.type == .passion ? "Passion" : "Execution")
            cell.headerLabel.text = header
            cell.fromLabel.text = (self.received! ? "from:" : "to:")
            cell.senderButton.setTitle(self.name, for: UIControlState.normal)
            cell.senderButton.addTarget(self, action: #selector(toCoworkerProfile), for: UIControlEvents.touchDown)
            
            if self.boostCard?.type == BoostCardType.execution {
                cell.iconView.backgroundColor = Tools.greenExecution
                cell.iconView.layer.cornerRadius = 10
                cell.iconImageView.image = UIImage(named: "execution-big")
            } else {
                cell.iconView.backgroundColor = Tools.redPassion
                cell.iconView.layer.cornerRadius = 10
                cell.iconImageView.image = UIImage(named: "passion-big")
            }
            
            return cell
        case .title:
            let cell = tableView.dequeueReusableCell(withIdentifier: "boostcardTitleCell", for: indexPath) as! BoostCardTitleViewCell
            
            cell.titleLabel.text = self.boostCard?.header
            cell.dateLabel.text = self.boostCard?.date.getCompleteString()
            
            return cell
        case .body:
            let cell = tableView.dequeueReusableCell(withIdentifier: "boostcardBodyCell", for: indexPath) as! BoostCardBodyViewCell
            
            cell.messageLabel.text = self.boostCard?.message
            
            return cell
        }
    }

}
