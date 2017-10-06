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
    case body
}

class BoostCardViewController: UITableViewController {
    
    var boostCard: BoostCard?
    var senderName: String?
    var senderMail: String?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
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
            
            cell.headerLabel.text = self.boostCard?.header
            cell.senderButton.setTitle(self.senderName, for: UIControlState.normal)
            
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
        case .body:
            let cell = tableView.dequeueReusableCell(withIdentifier: "boostcardBodyCell", for: indexPath) as! BoostCardBodyViewCell
            
            cell.messageTextView.text = self.boostCard?.message
            
            return cell
        }
    }

}
