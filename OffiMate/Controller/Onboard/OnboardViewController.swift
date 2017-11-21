//
//  OnboardViewController.swift
//  SingleSignUp
//
//  Created by Carlos Martin on 20/10/2017.
//  Copyright © 2017 Carlos Martin. All rights reserved.
//

import UIKit

enum OnboardSection: Int {
    case signup = 0
    case login
}

class OnboardViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }

    private func initUI() {
        var headerHeight: CGFloat = 165.0
        headerHeight -= self.navigationController!.navigationBar.frame.size.height
        self.tableView.contentInset = UIEdgeInsetsMake(headerHeight, 0, -headerHeight, 0)
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = true
            self.viewRespectsSystemMinimumLayoutMargins = false
        } else {
            // Fallback on earlier versions
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let onboardSection: OnboardSection = OnboardSection(rawValue: section)!
        switch onboardSection {
        case .signup:
            return 0.1
        case .login:
            return 15.0
        }
    }
 
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section: OnboardSection = OnboardSection(rawValue: indexPath.section)!
        switch section {
        case .signup:
            let cell = tableView.dequeueReusableCell(withIdentifier: "signupCell", for: indexPath) as! OnboardSignUpViewCell
            cell.signupButton.layer.cornerRadius = 12
            cell.signupButton.layer.backgroundColor = UIColor.white.cgColor
            return cell
        case .login:
            let cell = tableView.dequeueReusableCell(withIdentifier: "loginCell", for: indexPath) as! OnboardLoginViewCell
            cell.loginButton.layer.cornerRadius = 12
            cell.loginButton.layer.backgroundColor = UIColor.white.cgColor
            return cell
        }
    }
}
