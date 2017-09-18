//
//  MainViewController.swift
//  SingleSignUp
//
//  Created by Carlos Martin on 21/08/17.
//  Copyright © 2017 Carlos Martin. All rights reserved.
//

import UIKit

import Firebase

enum MainSection: Int {
    case current = 0
    case previous
}


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
    func getNumberOfRows() -> Int {
        let currentDay = Tools.getCurrentDayWeekNum()
        if currentDay >= 6 || currentDay == 1 {
            return 5
        } else {
            return currentDay - 1
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let currentSection: MainSection = MainSection(rawValue: section) {
            switch currentSection {
            case .current:
                return getNumberOfRows()
            case .previous:
                return 5
            }
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let currentSection: MainSection = MainSection(rawValue: section) {
            switch currentSection {
            case .current:
                return "Current week"
            case .previous:
                return "Week \(Tools.getWeekNum()-1)"
            }
        } else {
            return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let currentSection: MainSection = MainSection(rawValue: indexPath.section) {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "MainCell", for: indexPath) as? MainViewCell
            switch currentSection {
            case .current:
                switch indexPath.row {
                case 0:
                    cell?.label.text = "Today"
                    break
                default:
                    cell?.label.text = Tools.getCurrentDayName(weekDay: 6-indexPath.row)
                }
                return cell!
            case .previous:
                cell?.label.text = Tools.getCurrentDayName(weekDay: 6-indexPath.row)
                return cell!
            }
        } else {
            return UITableViewCell()
        }
    }

    
}


