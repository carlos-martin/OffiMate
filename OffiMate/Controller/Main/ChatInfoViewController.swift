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
    
    var isEditMode: Bool = false
    var isAdmin: Bool!
    var newName: String?
    var admin: Coworker?
    
    // From segue
    var channel: Channel?
    var unwindSegue: String?
    
    // UI
    var closeButton: UIBarButtonItem!
    var editButton: UIBarButtonItem!
    var spinner: SpinnerLoader!
    
    // Firebase
    private var members: [Coworker] = []
    private lazy var coworkerRef: DatabaseReference = Database.database().reference().child("coworkers")
    private var coworkerRefHandle: DatabaseHandle?

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
        
        if #available(iOS 11.0, *) {
            let outset: CGFloat = self.navigationController!.navigationBar.bounds.height
            self.spinner = SpinnerLoader(view: self.view, manualOutset: outset/2)
        } else {
            self.spinner = SpinnerLoader(view: self.view)
        }
        
        self.closeButton = UIBarButtonItem(
            image: UIImage(named: "close"),
            style: .plain,
            target: self,
            action: #selector(closeAction))
        
        self.navigationItem.leftBarButtonItem = closeButton
        
        self.isAdmin = (CurrentUser.user.uid == self.channel!.creator)
        
        if self.isAdmin {
            self.editButton = UIBarButtonItem(
                image: UIImage(named: "edit"),
                style: .plain,
                target: self,
                action: #selector(editAction))
            
            self.navigationItem.rightBarButtonItem = editButton
        }
        
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = true
        } else {
            // Fallback on earlier versions
        }
    }
    
    // MARK: - Firebase
    
    private func observeCoworkers() {
        self.spinner.start()
        Tools.fetchCoworker(uid: self.channel!.creator) { (_id: String?, _email: String?, _name: String?, _office: Office?) in
            if let id = _id, let email = _email, let name = _name, let office = _office {
                self.admin = Coworker(id: id, uid: self.channel!.creator, email: email, name: name, office: office)
            }
            
            self.coworkerRefHandle = self.coworkerRef.queryOrdered(byChild: "officeId").queryEqual(toValue: CurrentUser.office!.id).observe(.childAdded, with: { (snapshot: DataSnapshot) in
                self.spinner.stop()
                let coworkerData = snapshot.value as! Dictionary<String, AnyObject>
                let id = snapshot.key
                if let name = coworkerData["name"] as! String?, let email = coworkerData["email"] as! String?, let uid = coworkerData["userId"] as! String? {
                    let coworker = Coworker(id: id, uid: uid, email: email, name: name, office: CurrentUser.office!)
                    if self.channel!.creator != uid {
                        self.members.append(coworker)
                    }
                    self.tableView.reloadData()
                }
            })
            self.coworkerRef.queryOrdered(byChild: "officeId").queryEqual(toValue: CurrentUser.office!.id).observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
                self.spinner.stop()
                if snapshot.childrenCount == 0 {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    // MARK: - Navigation
    
    func updateTableView() {
        var indexSet = IndexSet()
        indexSet.insert(ChatInfoSection.members.rawValue)
        self.tableView.reloadSections(indexSet, with: .fade)
    }
    
    @objc private func closeAction() {
        self.performSegue(withIdentifier: self.unwindSegue!, sender: self)
    }
    
    @objc private func editAction() {
        if self.isEditMode {
            self.isEditMode = false
            self.editButton.image = UIImage(named: "edit")
            self.closeButton.isEnabled = true
            self.tableView.isScrollEnabled = true
            if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: ChatInfoSection.info.rawValue)) {
                let dataCell = cell as! ChatInfoViewCell
                dataCell.chatNameTextField.font = UIFont(name: ".SFUIText", size: 22)
                dataCell.chatNameTextField.backgroundColor = UIColor.white
                dataCell.chatNameTextField.layer.borderWidth = .leastNonzeroMagnitude
                dataCell.chatNameTextField.layer.borderColor = UIColor.white.cgColor
                dataCell.chatNameTextField.isEnabled = false
            }
            self.saveAction()
        } else {
            self.isEditMode = true
            self.editButton.image = UIImage(named: "save")
            self.closeButton.isEnabled = false
            self.tableView.isScrollEnabled = false
            if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: ChatInfoSection.info.rawValue)) {
                let dataCell = cell as! ChatInfoViewCell
                dataCell.chatNameTextField.font = UIFont(name: ".SFUIText-Italic", size: 22)
                dataCell.chatNameTextField.backgroundColor = UIColor.groupTableViewBackground.withAlphaComponent(0.5)
                dataCell.chatNameTextField.layer.borderWidth = 0.5
                dataCell.chatNameTextField.layer.borderColor = Tools.separator.cgColor
                dataCell.chatNameTextField.isEnabled = true
                dataCell.chatNameTextField.layer.cornerRadius = 12
            }
        }
        self.updateTableView()
    }
    
    private func saveAction() {
        
        let cell: ChatInfoViewCell = self.tableView.cellForRow(at: IndexPath(row: 0, section: ChatInfoSection.info.rawValue)) as! ChatInfoViewCell

        self.newName = (self.newName != nil ? self.newName : cell.chatNameTextField.text)
        
        if !self.newName!.isEmpty && self.newName! != self.channel!.name {
            Database.database().reference().child("channels").child(self.channel!.id).child("name").setValue(self.newName!)
            self.channel?.name = self.newName!
        } else {
            cell.chatNameTextField.text = self.channel!.name
        }
        
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let currentSection = ChatInfoSection(rawValue: section)!
        switch currentSection {
        case .info:
            return 1
        case .members:
            return (self.isEditMode ? 0 : self.members.count + (self.admin != nil ? 1 : 0))
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let currentSection = ChatInfoSection(rawValue: section)!
        switch currentSection {
        case .info:
            return CGFloat.leastNonzeroMagnitude
        default:
            return UITableViewAutomaticDimension
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let currentSection = ChatInfoSection(rawValue: section)!
        switch currentSection {
        case .info:
            return nil
        case .members:
            return (self.isEditMode ? nil : (self.members.isEmpty ? (self.admin != nil ? "members" : nil) : "members"))
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentSection = ChatInfoSection(rawValue: indexPath.section)!
        switch currentSection {
        case .members:
            let index = indexPath.row
            switch index {
            case 0:
                if self.admin!.uid != CurrentUser.user.uid {
                    self.toCoworkerProfile(coworker: self.admin!)
                }
                break
            default:
                let member: Coworker = self.members[indexPath.row-1]
                if member.uid != CurrentUser.user.uid {
                    self.toCoworkerProfile(coworker: member)
                }
                break
            }
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
            cell.chatNameTextField.delegate = self
            cell.selectionStyle = .none
            return cell
        case .members:
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "chatMemberCell", for: indexPath) as! ChatMembersViewCell
            let index = indexPath.row
            let member: Coworker
            switch index {
            case 0:
                member = self.admin!
                cell.adminLabel.isHidden = false
                cell.adminLabel.text = "admin"
            default:
                member = self.members[index-1]
                cell.adminLabel.isHidden = true
            }
            if member.uid == CurrentUser.user.uid {
                cell.selectionStyle = .none
                cell.memberLabel.font = UIFont.italicSystemFont(ofSize: 17.0)
            }
            cell.memberLabel.text = member.name
            return cell
        }
        
    }
}

// MARK: - UITextField

extension ChatInfoViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let name = textField.text {
            self.newName = name
        }
        textField.endEditing(true)
        self.editButton.isEnabled = true
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.editButton.isEnabled = false
    }
}
