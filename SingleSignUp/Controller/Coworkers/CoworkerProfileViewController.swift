//
//  CoworkerProfileViewController.swift
//  SingleSignUp
//
//  Created by Carlos Martin on 03/10/2017.
//  Copyright © 2017 Carlos Martin. All rights reserved.
//

import UIKit

class CoworkerProfileViewController: UITableViewController {

    var coworker: Coworker?
    var index:    Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
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

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "coworkerProfileCell", for: indexPath) as! CoworkerProfileViewCell
        cell.coworkerNameLabel.text  = self.coworker?.name
        cell.coworkerEmailLabel.text = self.coworker?.email
        cell.coworkerPictureProfile.layer.cornerRadius = cell.coworkerPictureProfile.frame.size.width / 2
        cell.coworkerPictureProfile.layer.borderWidth = 1.0
        cell.coworkerPictureProfile.layer.borderColor = Tools.separator.cgColor
        cell.coworkerPictureProfile.backgroundColor = Tools.backgrounsColors[index!]
        cell.coworkerPictureProfile.clipsToBounds = true
        return cell
    }

}
