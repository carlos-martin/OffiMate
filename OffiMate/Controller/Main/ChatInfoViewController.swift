//
//  ChatInfoViewController.swift
//  OffiMate
//
//  Created by Carlos Martin on 23/11/2017.
//  Copyright © 2017 Carlos Martin. All rights reserved.
//

import UIKit
import Firebase

enum ChatInfoSection: Int {
    case info = 0
    case members
}

class ChatInfoViewController: UITableViewController {
    
    var channel: Channel?
    var unwindSegue: String?
    
    // Firebase
    private var coworkers: [Coworker] = []
    private lazy var coworkerRef:       DatabaseReference = Database.database().reference().child("coworkers")
    private      var coworkerRefHandle: DatabaseHandle?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !Tools.isInternetAvailable() {
            Tools.goToWaitingRoom(vc: self)
        }
        if coworkerRefHandle == nil { self.observeCoworkers() }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func initUI() {
        self.navigationItem.title = "Channel Information"
        
        let backButton = UIBarButtonItem(
            image: UIImage(named: "close"),
            style: .plain,
            target: self,
            action: #selector(closeAction))
        
        self.navigationItem.leftBarButtonItem = backButton
        
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = true
        } else {
            // Fallback on earlier versions
        }
    }
    
    // MARK: - Firebase
    
    private func observeCoworkers() {
        self.coworkerRefHandle = self.coworkerRef.queryOrdered(byChild: "officeId").queryEqual(toValue: CurrentUser.office!.id).observe(.childAdded, with: { (snapshot: DataSnapshot) in
            let coworkerData = snapshot.value as! Dictionary<String, AnyObject>
            let id = snapshot.key
            if let name = coworkerData["name"] as! String!, let email = coworkerData["email"] as! String!, let uid = coworkerData["userId"] as! String! {
                if CurrentUser.user!.uid != uid {
                    let _coworker = Coworker(id: id, uid: uid, email: email, name: name, office: CurrentUser.office!)
                    self.coworkers.append(_coworker)
                    self.tableView.reloadData()
                }
            }
        })
        coworkerRef.queryOrdered(byChild: "officeId").queryEqual(toValue: CurrentUser.office!.id).observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
            if snapshot.childrenCount == 0 {
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Navigation
    
    @objc private func closeAction() {
        self.performSegue(withIdentifier: self.unwindSegue!, sender: self)
    }
    
    private func toCoworkerProfile (coworker: Coworker) {
        if let navigationController = UIStoryboard(name: "Coworkers", bundle: nil).instantiateViewController(withIdentifier: "CoworkerProfile") as? UINavigationController {
            if let controller = navigationController.viewControllers.first as? CoworkerProfileViewController {
                controller.modalPresentationStyle = .fullScreen
                controller.modalTransitionStyle = .coverVertical
                controller.coworker = coworker
                controller.unwindSegue = "unwindSegueToChatInfo"
                self.present(navigationController, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func unwindToChatInfo(segue: UIStoryboardSegue) {}
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let currentSection = ChatInfoSection(rawValue: section)!
        switch currentSection {
        case .info:
            return CGFloat.leastNonzeroMagnitude
        case .members:
            return UITableViewAutomaticDimension
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let currentSection = ChatInfoSection(rawValue: section)!
        switch currentSection {
        case .info:
            return 1
        case .members:
            return self.coworkers.count
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let currentSection = ChatInfoSection(rawValue: section)!
        switch currentSection {
        case .info:
            return nil
        case .members:
            return (self.coworkers.isEmpty ? nil : "members")
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentSection = ChatInfoSection(rawValue: indexPath.section)!
        switch currentSection {
        case .members:
            let member: Coworker = self.coworkers[indexPath.row]
            self.toCoworkerProfile(coworker: member)
        default:
            break
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentSection = ChatInfoSection(rawValue: indexPath.section)!
        switch currentSection {
        case .info:
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "chatInfoCell", for: indexPath) as! ChatInfoViewCell
            cell.chatNameTextField.text = self.channel?.name
            cell.chatNameTextField.isEnabled = false
            cell.selectionStyle = .none
            return cell
        case .members:
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "chatMemberCell", for: indexPath) as! ChatMembersViewCell
            let member: Coworker = self.coworkers[indexPath.row]
            cell.memberLabel.text = member.name
            if member.uid == self.channel!.creator {
                cell.adminLabel.isHidden = false
            } else {
                cell.adminLabel.isHidden = true
            }
            return cell
        }
        
    }
}
