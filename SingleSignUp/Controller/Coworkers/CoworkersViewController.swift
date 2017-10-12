//
//  CoworkersViewController.swift
//  SingleSignUp
//
//  Created by Carlos Martin on 27/09/2017.
//  Copyright © 2017 Carlos Martin. All rights reserved.
//

import UIKit
import Firebase

class CoworkersViewController: UITableViewController {
    
    //UI
    var spinner: SpinnerLoader?
    
    //Firebase
    private      var coworkers:         [Coworker] =        []
    private lazy var coworkerRef:       DatabaseReference = Database.database().reference().child("coworkers")
    private      var coworkerRefHandle: DatabaseHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initUI()
        self.observeCoworkers()
    }
    
    deinit {
        if let refHandle = coworkerRefHandle {
            coworkerRef.removeObserver(withHandle: refHandle)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func initUI() {
        self.navigationItem.title = "Coworkers"
        self.spinner = SpinnerLoader(view: self.view)
    }
    
    private func observeCoworkers() {
        self.spinner?.start()
        self.coworkerRefHandle = self.coworkerRef.observe(.childAdded, with: { (snapshot: DataSnapshot) in
            self.spinner?.stop()
            let coworkerData = snapshot.value as! Dictionary<String, AnyObject>
            let id = snapshot.key
            if let name = coworkerData["name"] as! String!, let email = coworkerData["email"] as! String!, let uid = coworkerData["userId"] as! String! {
                if CurrentUser.user!.uid != uid {
                    let _coworker = Coworker(id: id, uid: uid, email: email, name: name)
                    print(_coworker)
                    self.coworkers.append(_coworker)
                    self.tableView.reloadData()
                }
            }
        })
    }
    
    //MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showProfile" {
            if let indexPath = sender as? IndexPath {
                var controller: CoworkerProfileViewController
                if let navigationController = segue.destination as? UINavigationController {
                    controller = navigationController.topViewController as! CoworkerProfileViewController
                } else {
                    controller = segue.destination as! CoworkerProfileViewController
                }
                controller.coworker = self.coworkers[indexPath.row]
                controller.index = indexPath.row % Tools.backgrounsColors.count
            }
        }
    }
    
    @IBAction func unwindToCoworkers(segue: UIStoryboardSegue) {}
    
    //MARK: - Table View
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.coworkers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "coworkersCell", for: indexPath) as? CoworkersViewCell
        cell?.coworkerLabel.text = self.coworkers[indexPath.row].name
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "showProfile", sender: indexPath)
    }
}
