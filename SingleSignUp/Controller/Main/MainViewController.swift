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
    
    var         senderDisplayName:      String?
    private var currentChannels:        [Channel] = []
    private var previousChannels:       [Channel] = []
    var         detailViewController:   DetailViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initUI()
        self.initUser()
        self.initChannels()
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
    
    //MARK:- Init and Fetching Data
    
    func initUI() {
        let profileButton = UIBarButtonItem(
            image: UIImage(named: "user"),
            style: UIBarButtonItemStyle.plain,
            target: self,
            action: #selector(onboardActionButton(_:)))
        
        self.navigationItem.rightBarButtonItem = profileButton
        self.navigationItem.title = "OffiMate"
    }
    
    func initUser() {
        CurrentUser.date = NewDate(date: Date())
    }
    
    func initChannels() {
        func getNumberOfRows() -> Int {
            let weekDay = CurrentUser.date!.getWeekDay()
            if weekDay >= 6 || weekDay == 1 {
                return 5
            } else {
                return weekDay - 1
            }
        }
        
        if let date = CurrentUser.date {
            
            //MARK: init self.previousChannels
            let lower_index: Int
            let upper_index: Int
            switch date.getDayName() {
            case "Saturday":
                lower_index = 1
            case "Sunday":
                lower_index = 2
            case "Monday":
                lower_index = 3
            case "Tuesday":
                lower_index = 4
            case "Wednesday":
                lower_index = 5
            case "Thrusday":
                lower_index = 6
            case "Friday":
                lower_index = 7
            default:
                lower_index = 0
            }
            upper_index = lower_index+4
            
            for i in lower_index...upper_index {
                let _date    = Calendar.current.date(byAdding: .day, value: -i, to: date.date)!
                let _newDate = NewDate(date: _date)
                let channel  = Channel(id: _newDate.id.description, name: _newDate.getDayName())
                self.previousChannels.append(channel)
            }
            
            //MARK: init self.currentChannels
            let today = Channel(id: date.id.description, name: "Today")
            self.currentChannels.append(today)
            
            let rows = getNumberOfRows()
            for i in 1...(rows-1) {
                let _date    = Calendar.current.date(byAdding: .day, value: -i, to: date.date)!
                let _newDate = NewDate(date: _date)
                let channel  = Channel(id: _newDate.id.description, name: _newDate.getDayName())
                self.currentChannels.append(channel)
            }
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
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let currentSection: MainSection = MainSection(rawValue: section) {
            switch currentSection {
            case .current:
                return self.currentChannels.count
            case .previous:
                return self.previousChannels.count
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
                return "Week \(CurrentUser.date!.getWeekNum())"
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
                    cell?.label.text = self.currentChannels[indexPath.row].name
                }
                return cell!
            case .previous:
                cell?.label.text = self.previousChannels[indexPath.row].name
                return cell!
            }
        } else {
            return UITableViewCell()
        }
    }

    
}


