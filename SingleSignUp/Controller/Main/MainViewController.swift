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
    
    var         senderDisplayName:    String?
    private var channels:             [Channel] = []
    var         detailViewController: DetailViewController? = nil
    var         spinner:              SpinnerLoader?
    
    
    //Firebase variables
    private lazy var channelRef:        DatabaseReference = Database.database().reference().child("channels")
    private      var channelRefHandle:  DatabaseHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initUI()
        self.initChannels()
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
    
    private func initChannels() {
        //Use the observe method to listen for new channels being written to the Firebase DB
        self.channels.append(Channel(id: CurrentUser.date.id.description, name: CurrentUser.date.getDayName()))
        //        self.spinner?.start(self.view)
        //
        //        channelRefHandle = channelRef.observe(.childAdded, with: { (snapshot: DataSnapshot) in
        //            let channelData = snapshot.value as! Dictionary<String, AnyObject>
        //            let id = snapshot.key
        //            if let name = channelData["name"] as! String!, name.characters.count > 0 {
        //                self.channels.append(Channel(id: id, name: name))
        //                self.tableView.reloadData()
        //            } else {
        //                Alert.showFailiureAlert(message: "Error: Could not decode channel data")
        //            }
        //            self.spinner?.stop()
        //        })
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
        return self.channels.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Current week"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = self.tableView.dequeueReusableCell(withIdentifier: "MainCell", for: indexPath) as? MainViewCell {
            cell.label.text = "Today"
            return cell
        } else {
            return UITableViewCell()
        }
    }
}
