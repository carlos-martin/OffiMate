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
    @IBOutlet weak var emptyCoworkerLabel: UILabel!
    @IBOutlet weak var spinnerView: UIActivityIndicatorView!
    
    var stopLoading: Bool! {
        didSet {
            if self.stopLoading! {
                self.spinnerView.isHidden = true
                self.spinnerView.stopAnimating()
            } else {
                self.spinnerView.isHidden = false
                self.spinnerView.startAnimating()
            }
        }
    }
    
    var startLoading: Bool! {
        set { self.stopLoading = (newValue != nil ? !(newValue!) : true) }
        get { return !(self.stopLoading!) }
    }
    
    //Firebase
    private var coworkers: [Coworker] = [] {
        willSet {
            if newValue.isEmpty { self.emptyCoworkerLabel.isHidden = false }
            else { self.emptyCoworkerLabel.isHidden = true }
        }
    }
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
    
    deinit {
        if let refHandle = coworkerRefHandle {
            coworkerRef.removeObserver(withHandle: refHandle)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func initUI() {
        self.navigationItem.title = "Coworkers"
        self.tableView.reloadData()
    }
    
    private func observeCoworkers() {
        self.startLoading = true
        self.coworkerRefHandle = self.coworkerRef.queryOrdered(byChild: "officeId").queryEqual(toValue: CurrentUser.office!.id).observe(.childAdded, with: { (snapshot: DataSnapshot) in
            self.stopLoading = true
            let coworkerData = snapshot.value as! Dictionary<String, AnyObject>
            let id = snapshot.key
            if let name = coworkerData["name"] as! String?, let email = coworkerData["email"] as! String?, let uid = coworkerData["userId"] as! String? {
                if CurrentUser.user!.uid != uid {
                    let _coworker = Coworker(id: id, uid: uid, email: email, name: name, office: CurrentUser.office!)
                    self.coworkers.append(_coworker)
                    self.tableView.reloadData()
                }
            }
        })
        coworkerRef.queryOrdered(byChild: "officeId").queryEqual(toValue: CurrentUser.office!.id).observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
            if snapshot.childrenCount == 0 {
                self.stopLoading = true
                self.emptyCoworkerLabel.isHidden = false
            }
        }
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
                controller.unwindSegue = "unwindSegueToCoworkers"
            }
        }
    }
    
    @IBAction func unwindToCoworkers(segue: UIStoryboardSegue) {}
    
    //MARK: - Table View
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return (self.coworkers.isEmpty ? 18.0 : UITableViewAutomaticDimension)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return (self.coworkers.isEmpty ? nil : "your office coworkers")
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
