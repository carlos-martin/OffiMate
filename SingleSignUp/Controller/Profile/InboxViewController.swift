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
    
    //BoostCard
    private var boostCards: [BoostCard] = [BoostCard]()
    private var senderName: [String] = [String]()
    private var senderMail: [String] = [String]()
    
    
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Segue showBoostCard
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
                controller.boostCard =  self.boostCards[row]
                controller.senderName = self.senderName[row]
                controller.senderMail = self.senderMail[row]
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "showBoostCard", sender: indexPath)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "inboxCell", for: indexPath) as! InboxViewCell
        let row = indexPath.row
        let boostCard = self.boostCards[row]
        cell.senderLabel.text = self.senderName[row]
        cell.headerLabel.text = "\(boostCard.type): \(boostCard.header)"
        cell.messangeLabel.text = boostCard.message
        return cell
    }
    
    // MARK: - Firebase related methods
    
    private func observerBoostcards() {
        self.spinner?.start(self.tableView)
        let receiver = CurrentUser.user!.uid
        boostCardRefQuery = boostCardRef.queryOrdered(byChild: "receiverId").queryEqual(toValue: receiver)
        boostCardRefQuery?.observe(.value, with: { (snapshot: DataSnapshot) in
            let rawData = snapshot.value as! Dictionary<String, AnyObject>
            var counter = rawData.count
            for entry in rawData {
                let header =    entry.value["header"]   as! String
                let message =   entry.value["message"]  as! String
                let senderId =  entry.value["senderId"] as! String
                let _type =     entry.value["type"]     as! String
                let type = (_type == "passion" ? BoostCardType(rawValue: 0) : BoostCardType(rawValue: 1))!
                
                Tools.fetchCoworker(uid: senderId, completion: { (_email: String?, _name: String?) in
                    if let email = _email, let name = _name {
                        self.senderMail.append(email)
                        self.senderName.append(name)
                        self.boostCards.append(
                            BoostCard(
                                id:         entry.key,
                                senderId:   senderId,
                                receiverId: receiver,
                                type:       type,
                                header:     header,
                                message:    message)
                        )
                    }
                    counter -= 1
                    if counter == 0 {
                        self.spinner?.stop()
                        self.tableView.reloadData()
                    }
                })
            }
        })
        
    }

}
