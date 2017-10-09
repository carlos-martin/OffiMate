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

    var spinner: SpinnerLoader?
    @IBOutlet weak var emptyInboxLabel: UILabel!
    
    var counter: Int = 0
    
    //BoostCard
    private var boostCards: [(BoostCard, String, String, Bool)] = [] {
        didSet {
            boostCards.sort { $0.0 > $1.0 }
        }
    }
    
    private var _boostCards: [BoostCard] = []
    
    
    //Firebase variables
    private lazy var boostCardRef:       DatabaseReference = Database.database().reference().child("boostcard")
    private      var boostCardRefQuery:  DatabaseQuery?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initUI()
        self.observerBoostcards()
    }
    
    func initUI() {
        self.spinner = SpinnerLoader(view: self.tableView)
        self.emptyInboxLabel.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Segue showBoostCard
    
    private func mackAsRead (indexPath: IndexPath) {
        let readRef = boostCardRef.child(self.boostCards[indexPath.row].0.id)
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
                
                controller.boostCard =  self.boostCards[row].0//boostCard
                controller.senderName = self.boostCards[row].1//name
                controller.senderMail = self.boostCards[row].2//email
            }
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.boostCards.count
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
        
        if self.boostCards[indexPath.row].3 {
            self.boostCards[indexPath.row].3 = false
            self.mackAsRead(indexPath: indexPath)
        }
        
        performSegue(withIdentifier: "showBoostCard", sender: indexPath)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "inboxCell", for: indexPath) as! InboxViewCell
        let row = indexPath.row
        let boostCard = self.boostCards[row].0
        cell.readedImage.isHidden = !self.boostCards[row].3
        cell.senderLabel.text = self.boostCards[row].1
        cell.headerLabel.text = "\(boostCard.type): \(boostCard.header)"
        cell.dateLabel.text = "\(boostCard.date)"
        cell.messangeLabel.text = boostCard.message
        return cell
    }
    
    // MARK: - Firebase related methods
    
    private func observerBoostcards() {
        self.spinner?.start(self.tableView)
        let receiver = CurrentUser.user!.uid
        boostCardRefQuery = boostCardRef.queryOrdered(byChild: "receiverId").queryEqual(toValue: receiver)
        boostCardRefQuery?.observe(.value, with: { (snapshot: DataSnapshot) in
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
                    
                    Tools.fetchCoworker(uid: senderId, completion: { (_email: String?, _name: String?, _) in
                        if let email = _email, let name = _name {
                            let newdate: NewDate
                            do {
                                newdate = try NewDate(id: date)
                            } catch {
                                newdate = NewDate(date: Date())
                            }
                            
                            let boostCard = BoostCard(
                                id:         entry.key,
                                senderId:   senderId,
                                receiverId: receiver,
                                type:       type,
                                header:     header,
                                message:    message,
                                date:       newdate)
                            
                            if !self._boostCards.contains(boostCard) {
                                self._boostCards.append(boostCard)
                                let element = (boostCard, name, email, unread)
                                self.boostCards.append(element)
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
