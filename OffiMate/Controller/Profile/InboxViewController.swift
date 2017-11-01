//
//  InboxViewController.swift
//  SingleSignUp
//
//  Created by Carlos Martin on 05/10/2017.
//  Copyright © 2017 Carlos Martin. All rights reserved.
//

import UIKit
import Firebase

class InboxViewController: UITableViewController {

    var counter: Int = 0
    var spinner: SpinnerLoader?
    
    var received: Bool?
    
    @IBOutlet weak var emptyInboxLabel: UILabel!
    
    //BoostCard
    private var boostcards: [(BoostCard, String, String, Bool)] = [] { didSet { boostcards.sort { $0.0 > $1.0 } } }
    private var _boostcards: [BoostCard] = []
    
    //Firebase variables
    private lazy var boostcardRef:  DatabaseReference = Database.database().reference().child("boostcard")
    private var boostcardRefHandle: DatabaseHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initUI()
        if received! {
            self.observerReceivedBoostcards()
        } else {
            self.observerSentBoostcards()
        }
    }
    
    func initUI() {
        self.spinner = SpinnerLoader(view: self.tableView)
        self.emptyInboxLabel.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !Tools.isInternetAvailable() {
            Tools.goToWaitingRoom(vc: self)
        }
    }
    
    deinit {
        if let refBoostcardHandle = boostcardRefHandle {
            boostcardRef.removeObserver(withHandle: refBoostcardHandle)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Segue showBoostCard
    
    private func markAsRead (indexPath: IndexPath) {
        let readRef = boostcardRef.child(self.boostcards[indexPath.row].0.id)
        readRef.child("unread").setValue(false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showBoostCard" {
            if let indexPath = sender as? IndexPath {
                let row = indexPath.row
                
                var controller: BoostCardViewController
                if let navigationController = segue.destination as? UINavigationController {
                    controller = navigationController.topViewController as! BoostCardViewController
                } else {
                    controller = segue.destination as! BoostCardViewController
                }
                
                controller.boostCard =  self.boostcards[row].0//boostCard
                controller.name = self.boostcards[row].1//name
                controller.mail = self.boostcards[row].2//email
                controller.received = self.received
            }
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.boostcards.count
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        if self.received! {
            if self.boostcards[indexPath.row].3 {
                self.boostcards[indexPath.row].3 = false
                self.markAsRead(indexPath: indexPath)
            }
        }
        
        performSegue(withIdentifier: "showBoostCard", sender: indexPath)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "inboxCell", for: indexPath) as! InboxViewCell
        let row = indexPath.row
        let boostCard = self.boostcards[row].0
        if self.received! {
            cell.readedImage.isHidden = !self.boostcards[row].3
        } else {
            cell.readedImage.isHidden = true
        }
        
        cell.senderLabel.text = self.boostcards[row].1
        cell.headerLabel.text = "\(boostCard.type): \(boostCard.header)"
        cell.dateLabel.text = "\(boostCard.date)"
        cell.messangeLabel.text = boostCard.message
        return cell
    }
    
    // MARK: - Firebase related methods
    private func observerSentBoostcards() {
        self.spinner?.start()
        let senderId = CurrentUser.user!.uid
        self.boostcardRefHandle = boostcardRef.queryOrdered(byChild: "senderId").queryEqual(toValue: senderId).observe(.value, with: { (snapshot: DataSnapshot) in
            if let rawData = snapshot.value as? Dictionary<String, AnyObject> {
                var counter = rawData.count
                for entry in rawData {
                    let header =        entry.value["header"]       as! String
                    let message =       entry.value["message"]      as! String
                    let receiverId =    entry.value["receiverId"]   as! String
                    let unread =        entry.value["unread"]       as! Bool
                    let date =          entry.value["date"]         as! Int64
                    let _type =         entry.value["type"]         as! String
                    let type = (_type == "passion" ? BoostCardType(rawValue: 0) : BoostCardType(rawValue: 1))!
                    
                    Tools.fetchCoworker(uid: receiverId, completion: { (_, _email: String?, _name: String?, _) in
                        if let email = _email, let name = _name {
                            let newdate: NewDate
                            newdate = NewDate(id: date)
                            
                            let boostCard = BoostCard(
                                id:         entry.key,
                                senderId:   senderId,
                                receiverId: receiverId,
                                type:       type,
                                header:     header,
                                message:    message,
                                date:       newdate)
                            
                            if !self._boostcards.contains(boostCard) {
                                self._boostcards.append(boostCard)
                                let element = (boostCard, name, email, unread)
                                self.boostcards.append(element)
                            }
                        }
                        counter -= 1
                        if counter == 0 {
                            self.spinner?.stop()
                            self.tableView.reloadData()
                        }
                    })
                }
            } else {
                self.spinner?.stop()
                self.emptyInboxLabel.isHidden = (self.emptyInboxLabel.isHidden ? false : true)
            }
        })
    }
    
    private func observerReceivedBoostcards() {
        self.spinner?.start()
        let receiverId = CurrentUser.user!.uid
        self.boostcardRefHandle = boostcardRef.queryOrdered(byChild: "receiverId").queryEqual(toValue: receiverId).observe(.value, with: { (snapshot: DataSnapshot) in
            if let rawData = snapshot.value as? Dictionary<String, AnyObject> {
                var counter = rawData.count
                for entry in rawData {
                    let header =    entry.value["header"]   as! String
                    let message =   entry.value["message"]  as! String
                    let senderId =  entry.value["senderId"] as! String
                    let unread =    entry.value["unread"]   as! Bool
                    let date =      entry.value["date"]     as! Int64
                    let _type =     entry.value["type"]     as! String
                    let type = (_type == "passion" ? BoostCardType(rawValue: 0) : BoostCardType(rawValue: 1))!
                    
                    Tools.fetchCoworker(uid: senderId, completion: { (_, _email: String?, _name: String?, _) in
                        if let email = _email, let name = _name {
                            let newdate: NewDate
                            newdate = NewDate(id: date)
                            
                            let boostCard = BoostCard(
                                id:         entry.key,
                                senderId:   senderId,
                                receiverId: receiverId,
                                type:       type,
                                header:     header,
                                message:    message,
                                date:       newdate)
                            
                            if !self._boostcards.contains(boostCard) {
                                self._boostcards.append(boostCard)
                                let element = (boostCard, name, email, unread)
                                self.boostcards.append(element)
                            }
                        }
                        counter -= 1
                        if counter == 0 {
                            self.spinner?.stop()
                            self.tableView.reloadData()
                        }
                    })
                }
            } else {
                self.spinner?.stop()
                self.emptyInboxLabel.isHidden = (self.emptyInboxLabel.isHidden ? false : true)
            }
        })
    }

}
