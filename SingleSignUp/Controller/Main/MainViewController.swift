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
    case createNewChannel = 0
    case currentChannel
}

class MainViewController: UITableViewController {
    
    var         senderDisplayName:    String?
    private var channels:             [Channel] = []
    var         spinner:              SpinnerLoader?
    var         newChannel:           Channel?
    
    //Firebase variables
    private lazy var channelRef:        DatabaseReference = Database.database().reference().child("channels")
    private      var channelRefHandle:  DatabaseHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initUI()
        self.observeChannels()
    }
    
    deinit {
        if let refHandle = channelRefHandle {
            channelRef.removeObserver(withHandle: refHandle)
        }
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
    
    //MARK:- Init and Fetching Data Functions
    
    private func initUI() {
        let profileButton = UIBarButtonItem(
            image: UIImage(named: "user"),
            style: UIBarButtonItemStyle.plain,
            target: self,
            action: #selector(onboardActionButton(_:)))
        
        self.navigationItem.rightBarButtonItem = profileButton
        self.navigationItem.title = "OffiMate"
        self.spinner = SpinnerLoader(view: self.view)
    }
    
    //MARK: Firebase related methods
    
    private func observeChannels() {
        //Use the observe method to listen for new channels being written to the Firebase DB
        //self.channels.append(Channel(id: CurrentUser.date.id.description, name: CurrentUser.date.getDayName()))

        self.spinner?.start(self.view)
        channelRefHandle = channelRef.observe(.childAdded, with: { (snapshot: DataSnapshot) in
            self.spinner?.stop()
            let channelData = snapshot.value as! Dictionary<String, AnyObject>
            let id = snapshot.key
            if let name = channelData["name"] as! String!, name.characters.count > 0 {
                self.channels.append(Channel(id: id, name: name))
                self.tableView.reloadData()
            }
        })
    }
    
    @objc func createChannel(_ sender: Any? = nil) {
        if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? NewChannelViewCell {
            if !cell.newChannelTextField.text!.isEmpty {
                let name = cell.newChannelTextField.text!
                let newChannelRef = channelRef.childByAutoId()
                let channelItem = [
                    "name": name
                ]
                newChannelRef.setValue(channelItem)
                cell.newChannelTextField.text! = ""
            } else {
                Tools.textFieldErrorAnimation(textField: cell.newChannelTextField)
            }
        } else {
            Alert.showFailiureAlert(message: "Oops! Something goes wroung!")
        }
    }
    
    //MARK:- Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                var controller: ChatViewController
                if let navigationController = segue.destination as? UINavigationController {
                    controller = navigationController.topViewController as! ChatViewController
                } else {
                    controller = segue.destination as! ChatViewController
                }
                let channel = self.channels[indexPath.row]
                controller.channel = channel
                controller.channelRef = channelRef.child(channel.id)
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
            case .createNewChannel:
                return 1
            case .currentChannel:
                return self.channels.count
            }
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let currentSection: MainSection = MainSection(rawValue: section) {
            switch currentSection {
            case .createNewChannel:
                return 0.1
            case .currentChannel:
                return 30.0
            }
        } else {
            return 0.1
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let currentSection: MainSection = MainSection(rawValue: section) {
            switch currentSection {
            case .createNewChannel:
                return nil
            case .currentChannel:
                return "Channels"
            }
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let currentSection: MainSection = MainSection(rawValue: indexPath.section) {
            switch currentSection {
            case .createNewChannel:
                let cell = self.tableView.dequeueReusableCell(withIdentifier: "NewChannelCell", for: indexPath) as? NewChannelViewCell
                cell?.newChannelTextField.delegate = self
                cell?.newChannelTextField.placeholder = "Create a New Channel"
                cell?.addChannelButton.addTarget(
                    self,
                    action: #selector(createChannel(_:)),
                    for: .touchUpInside)
                cell?.selectionStyle = .none
                return cell!
            case .currentChannel:
                let cell = self.tableView.dequeueReusableCell(withIdentifier: "MainCell", for: indexPath) as? MainViewCell
                cell?.label.text = self.channels[indexPath.row].name
                return cell!
            }
        } else {
            return UITableViewCell()
        }
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.onDrag
    }
}

extension MainViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //TODO: add action to create a channel
        self.createChannel(nil)
        self.view.endEditing(true)
        return true
    }
}
