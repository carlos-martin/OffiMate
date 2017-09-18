//
//  MainViewController.swift
//  SingleSignUp
//
//  Created by Carlos Martin on 21/08/17.
//  Copyright © 2017 Carlos Martin. All rights reserved.
//

import UIKit

class MainViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let profileButton = UIBarButtonItem(
            image: UIImage(named: "user"),
            style: UIBarButtonItemStyle.plain,
            target: self,
            action: #selector(onboardActionButton(_:)))
        
        self.navigationItem.rightBarButtonItem = profileButton
        self.navigationItem.title = "OffiMate"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let split = self.splitViewController {
            self.clearsSelectionOnViewWillAppear = split.isCollapsed
        }
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func onboardActionButton(_ sender: Any) {
        if CurrentUser.isInit() {
            Tools.goToProfile(vc: self)
        } else {
            Tools.goToOnboard(vc: self)
        }
    }
    
    //MARK:- Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                var controller: DetailViewController
                if let navigationController = segue.destination as? UINavigationController {
                    controller = navigationController.topViewController as! DetailViewController
                } else {
                    controller = segue.destination as! DetailViewController
                }
                controller.navigationItem.title = (self.tableView.cellForRow(at: indexPath) as! MainViewCell).label.text
                controller.auto = false
            }
        }
    }
    
    //MARK:- Table View
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Current Week"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "MainCell", for: indexPath) as? MainViewCell
        switch indexPath.row {
        case 0:
            cell?.label.text = "Today"
        case 1:
            cell?.label.text = "Yesterday"
        default:
            cell?.label.text = "Two days ago"
        }
        return cell!
    }

    
}


